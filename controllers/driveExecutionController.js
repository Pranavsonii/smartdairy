import pool from "../config/database.js";

export const getDriveExecution = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if drive exists and is ongoing
    const driveResult = await pool.query(
      `SELECT d.*, r.name as route_name, dg.name as delivery_guy_name
       FROM drives d
       LEFT JOIN routes r ON d.route_id = r.route_id
       LEFT JOIN delivery_guys dg ON d.delivery_guy_id = dg.delivery_guy_id
       WHERE d.drive_id = $1`,
      [id]
    );

    if (driveResult.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    const drive = driveResult.rows[0];

    if (drive.status !== "ongoing") {
      return res
        .status(400)
        .json({ message: "Drive is not currently ongoing" });
    }

    // Get customers in the route with their delivery status
    const customersResult = await pool.query(
      `SELECT c.customer_id, c.name, c.phone, c.location, c.address, c.price, c.default_quantity,
              COALESCE(dcs.status, 'pending') as delivery_status,
              COALESCE(dcs.quantity, 0) as delivered_quantity,
              COALESCE(dcs.total_amount, 0) as delivered_amount
       FROM customers c
       JOIN route_customers rc ON c.customer_id = rc.customer_id
       LEFT JOIN drive_customers_sales dcs ON c.customer_id = dcs.customer_id AND dcs.drive_id = $1
       WHERE rc.route_id = $2 AND c.status = 'active'
       ORDER BY c.name`,
      [id, drive.route_id]
    );

    // Get drive sales summary
    const salesSummary = await pool.query(
      `SELECT COUNT(*) as customers_served,
              SUM(quantity) as quantity_delivered,
              SUM(total_amount) as total_amount,
              COUNT(CASE WHEN status = 'success' THEN 1 END) as successful_deliveries,
              COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_deliveries
       FROM drive_customers_sales
       WHERE drive_id = $1`,
      [id]
    );

    // Get total route customers for progress calculation
    const total_customersResult = await pool.query(
      `SELECT COUNT(*) as total_customers
       FROM route_customers rc
       JOIN customers c ON rc.customer_id = c.customer_id
       WHERE rc.route_id = $1 AND c.status = 'active'`,
      [drive.route_id]
    );

    const total_customers = parseInt(
      total_customersResult.rows[0].totalcustomers
    );
    const servedCustomers = parseInt(salesSummary.rows[0].customersserved) || 0;

    const progress = {
      total_customers,
      servedCustomers,
      remainingCustomers: total_customers - servedCustomers,
      completionPercentage:
        total_customers > 0 ? (servedCustomers / total_customers) * 100 : 0,
      quantity_delivered: parseInt(salesSummary.rows[0].quantitydelivered) || 0,
      total_amount: parseFloat(salesSummary.rows[0].totalamount) || 0,
      successful_deliveries:
        parseInt(salesSummary.rows[0].successfuldeliveries) || 0,
      failed_deliveries: parseInt(salesSummary.rows[0].faileddeliveries) || 0
    };

    res.json({
      drive,
      customers: customersResult.rows,
      progress
    });
  } catch (error) {
    console.error("Get drive execution error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const recordSale = async (req, res) => {
  try {
    const { id } = req.params;
    const { customer_id, quantity, price, status = "success" } = req.body;

    // Removed quantity from required fields check
    if (!customer_id || !price) {
      return res
        .status(400)
        .json({ message: "Customer ID and price are required" });
    }

    // Check if drive exists and is ongoing
    const driveCheck = await pool.query(
      "SELECT * FROM drives WHERE drive_id = $1",
      [id]
    );

    if (driveCheck.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    if (driveCheck.rows[0].status !== "ongoing") {
      return res.status(400).json({ message: "Drive is not ongoing" });
    }

    // Check if customer exists
    const customerCheck = await pool.query(
      "SELECT customer_id FROM customers WHERE customer_id = $1",
      [customer_id]
    );

    if (customerCheck.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    // Check if customer is in the drive's route
    const routeCustomerCheck = await pool.query(
      `SELECT rc.route_customer_id
       FROM route_customers rc
       JOIN drives d ON rc.route_id = d.route_id
       WHERE d.drive_id = $1 AND rc.customer_id = $2`,
      [id, customer_id]
    );

    if (routeCustomerCheck.rows.length === 0) {
      return res
        .status(400)
        .json({ message: "Customer is not in the drive's route" });
    }

    // Check if a sale for this customer already exists in this drive
    const existingSaleCheck = await pool.query(
      "SELECT * FROM drive_customers_sales WHERE drive_id = $1 AND customer_id = $2",
      [id, customer_id]
    );

    // Use provided quantity or default to 1
    const saleQuantity = quantity || 1;

    // Calculate total amount
    const total_amount = saleQuantity * price;

    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      let result;

      if (existingSaleCheck.rows.length > 0) {
        // Update existing sale
        result = await client.query(
          `UPDATE drive_customers_sales
           SET quantity = $1, price = $2, total_amount = $3, status = $4, updated_at = NOW()
           WHERE drive_id = $5 AND customer_id = $6
           RETURNING *`,
          [saleQuantity, price, total_amount, status, id, customer_id]
        );
      } else {
        // Create new sale
        result = await client.query(
          `INSERT INTO drive_customers_sales
           (drive_id, customer_id, quantity, price, total_amount, status)
           VALUES ($1, $2, $3, $4, $5, $6)
           RETURNING *`,
          [id, customer_id, saleQuantity, price, total_amount, status]
        );
      }

      // Update drive sold count
      await client.query(
        `UPDATE drives
         SET sold = (SELECT SUM(quantity) FROM drive_customers_sales WHERE drive_id = $1),
         updated_at = NOW()
         WHERE drive_id = $1`,
        [id]
      );

      await client.query("COMMIT");

      res.status(existingSaleCheck.rows.length > 0 ? 200 : 201).json({
        message: `Sale ${
          existingSaleCheck.rows.length > 0 ? "updated" : "recorded"
        } successfully`,
        sale: result.rows[0]
      });
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Record sale error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const skipCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    const { customer_id, reason } = req.body;

    if (!customer_id) {
      return res.status(400).json({ message: "Customer ID is required" });
    }

    // Check if drive exists and is ongoing
    const driveCheck = await pool.query(
      "SELECT * FROM drives WHERE drive_id = $1",
      [id]
    );

    if (driveCheck.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    if (driveCheck.rows[0].status !== "ongoing") {
      return res.status(400).json({ message: "Drive is not ongoing" });
    }

    // Check if customer exists
    const customerCheck = await pool.query(
      "SELECT * FROM customers WHERE customer_id = $1",
      [customer_id]
    );

    if (customerCheck.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    // Check if customer is in the drive's route
    const routeCustomerCheck = await pool.query(
      `SELECT rc.route_customer_id
       FROM route_customers rc
       JOIN drives d ON rc.route_id = d.route_id
       WHERE d.drive_id = $1 AND rc.customer_id = $2`,
      [id, customer_id]
    );

    if (routeCustomerCheck.rows.length === 0) {
      return res
        .status(400)
        .json({ message: "Customer is not in the drive's route" });
    }

    // Record as failed delivery with 0 quantity
    const result = await pool.query(
      `INSERT INTO drive_customers_sales
       (drive_id, customer_id, quantity, price, total_amount, status, remarks)
       VALUES ($1, $2, 0, $3, 0, 'failed', $4)
       ON CONFLICT (drive_id, customer_id)
       DO UPDATE SET
         status = 'failed',
         quantity = 0,
         total_amount = 0,
         remarks = $4
       RETURNING *`,
      [
        id,
        customer_id,
        customerCheck.rows[0].price,
        reason || "Customer skipped"
      ]
    );

    res.json({
      message: "Customer skipped successfully",
      skippedDelivery: result.rows[0]
    });
  } catch (error) {
    console.error("Skip customer error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const scanQrCode = async (req, res) => {
  try {
    const { id } = req.params;
    const { qrCode, quantity } = req.body;

    if (!qrCode) {
      return res.status(400).json({ message: "QR code is required" });
    }

    // Check if drive exists and is ongoing
    const driveCheck = await pool.query(
      "SELECT * FROM drives WHERE drive_id = $1",
      [id]
    );

    if (driveCheck.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    if (driveCheck.rows[0].status !== "ongoing") {
      return res.status(400).json({ message: "Drive is not ongoing" });
    }

    // Find QR code and associated customer
    const qrCodeCheck = await pool.query(
      `SELECT q.*, c.customer_id, c.name, c.phone, c.price, c.default_quantity
       FROM qr_codes q
       JOIN customers c ON q.customer_id = c.customer_id
       WHERE q.code = $1 AND q.status = 'active'`,
      [qrCode]
    );

    if (qrCodeCheck.rows.length === 0) {
      return res.status(404).json({ message: "QR code not found or inactive" });
    }

    const qrCodeData = qrCodeCheck.rows[0];

    // Check if customer is in the drive's route
    const routeCustomerCheck = await pool.query(
      `SELECT rc.route_customer_id
       FROM route_customers rc
       JOIN drives d ON rc.route_id = d.route_id
       WHERE d.drive_id = $1 AND rc.customer_id = $2`,
      [id, qrCodeData.customer_id]
    );

    if (routeCustomerCheck.rows.length === 0) {
      return res
        .status(400)
        .json({ message: "Customer is not in the drive's route" });
    }

    // Use provided quantity or default quantity from customer
    const deliveryQuantity = quantity || qrCodeData.defaultquantity;
    const total_amount = deliveryQuantity * qrCodeData.price;

    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // Record sale
      const saleResult = await client.query(
        `INSERT INTO drive_customers_sales
         (drive_id, customer_id, qr_id, quantity, price, total_amount, status)
         VALUES ($1, $2, $3, $4, $5, $6, 'success')
         ON CONFLICT (drive_id, customer_id)
         DO UPDATE SET
           quantity = $4,
           price = $5,
           total_amount = $6,
           status = 'success',
           qr_id = $3
         RETURNING *`,
        [
          id,
          qrCodeData.customer_id,
          qrCodeData.qrid,
          deliveryQuantity,
          qrCodeData.price,
          total_amount
        ]
      );

      // Update drive sold count
      await client.query(
        `UPDATE drives
         SET sold = (SELECT SUM(quantity) FROM drive_customers_sales WHERE drive_id = $1),
         updated_at = NOW()
         WHERE drive_id = $1`,
        [id]
      );

      await client.query("COMMIT");

      res.json({
        message: "QR code scanned and sale recorded successfully",
        customer: {
          customer_id: qrCodeData.customer_id,
          name: qrCodeData.name,
          phone: qrCodeData.phone
        },
        sale: saleResult.rows[0]
      });
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Scan QR code error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDriveProgress = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if drive exists
    const driveCheck = await pool.query(
      "SELECT * FROM drives WHERE drive_id = $1",
      [id]
    );

    if (driveCheck.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    const drive = driveCheck.rows[0];

    // Get drive sales summary
    const salesSummary = await pool.query(
      `SELECT COUNT(*) as customers_served,
              SUM(quantity) as quantity_delivered,
              SUM(total_amount) as total_amount,
              COUNT(CASE WHEN status = 'success' THEN 1 END) as successful_deliveries,
              COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_deliveries
       FROM drive_customers_sales
       WHERE drive_id = $1`,
      [id]
    );

    // Get total route customers for progress calculation
    const total_customersResult = await pool.query(
      `SELECT COUNT(*) as total_customers
       FROM route_customers rc
       JOIN customers c ON rc.customer_id = c.customer_id
       WHERE rc.route_id = $1 AND c.status = 'active'`,
      [drive.route_id]
    );

    const total_customers = parseInt(
      total_customersResult.rows[0].totalcustomers
    );
    const servedCustomers = parseInt(salesSummary.rows[0].customersserved) || 0;

    // Get last location
    const lastLocationResult = await pool.query(
      `SELECT
        ST_X(location::geometry) as longitude,
        ST_Y(location::geometry) as latitude,
        time
       FROM drive_locations_log
       WHERE drive_id = $1
       ORDER BY time DESC
       LIMIT 1`,
      [id]
    );

    const progress = {
      driveStatus: drive.status,
      start_time: drive.starttime,
      end_time: drive.endtime,
      elapsedTime: drive.starttime
        ? Math.floor((new Date() - new Date(drive.starttime)) / 1000)
        : null,
      total_customers,
      servedCustomers,
      remainingCustomers: total_customers - servedCustomers,
      completionPercentage:
        total_customers > 0 ? (servedCustomers / total_customers) * 100 : 0,
      quantity_delivered: parseInt(salesSummary.rows[0].quantitydelivered) || 0,
      total_amount: parseFloat(salesSummary.rows[0].totalamount) || 0,
      successful_deliveries:
        parseInt(salesSummary.rows[0].successfuldeliveries) || 0,
      failed_deliveries: parseInt(salesSummary.rows[0].faileddeliveries) || 0,
      stock: drive.stock,
      remainingStock:
        drive.stock - (parseInt(salesSummary.rows[0].quantitydelivered) || 0),
      lastLocation: lastLocationResult.rows[0] || null
    };

    res.json({ progress });
  } catch (error) {
    console.error("Get drive progress error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const reconcileDrive = async (req, res) => {
  try {
    const { id } = req.params;
    const { sold, returned, remarks } = req.body;

    // Check if drive exists and is ongoing
    const driveCheck = await pool.query(
      "SELECT * FROM drives WHERE drive_id = $1",
      [id]
    );

    if (driveCheck.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    if (driveCheck.rows[0].status !== "ongoing") {
      return res
        .status(400)
        .json({ message: "Only ongoing drives can be reconciled" });
    }

    // Get current sales total from drive_customers_sales
    const salesResult = await pool.query(
      "SELECT COALESCE(SUM(quantity), 0) as totalSold, COALESCE(SUM(total_amount), 0) as total_amount FROM drive_customers_sales WHERE drive_id = $1",
      [id]
    );

    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // Update drive with reconciled values
      const totalSold = sold || parseInt(salesResult.rows[0].totalsold) || 0;
      const total_amount = parseFloat(salesResult.rows[0].totalamount) || 0;
      const stockReturned = returned || driveCheck.rows[0].stock - totalSold;

      const result = await client.query(
        `UPDATE drives
         SET sold = $1,
             returned = $2,
             remarks = $3,
             total_amount = $4,
             updated_at = NOW()
         WHERE drive_id = $5
         RETURNING *`,
        [totalSold, stockReturned, remarks || null, total_amount, id]
      );

      await client.query("COMMIT");

      res.json({
        message: "Drive reconciled successfully",
        drive: result.rows[0]
      });
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Reconcile drive error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
