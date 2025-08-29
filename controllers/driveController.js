import pool from "../config/database.js";

export const getDrives = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 500,
      status,
      date,
      delivery_guy_id,
      route_id
    } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT d.*, r.name as route_name, dg.name as delivery_guy_name
      FROM drives d
      LEFT JOIN routes r ON d.route_id = r.route_id
      LEFT JOIN delivery_guys dg ON d.delivery_guy_id = dg.delivery_guy_id
      WHERE 1=1
    `;

    const params = [];

    if (status) {
      params.push(status);
      query += ` AND d.status = $${params.length}`;
    }

    if (date) {
      params.push(`${date}%`);
      query += ` AND CAST(d.created_at AS TEXT) LIKE $${params.length}`;
    }

    if (delivery_guy_id) {
      params.push(delivery_guy_id);
      query += ` AND d.delivery_guy_id = $${params.length}`;
    }

    if (route_id) {
      params.push(route_id);
      query += ` AND d.route_id = $${params.length}`;
    }

    // Add order by and pagination
    query += ` ORDER BY d.created_at DESC LIMIT $${params.length + 1} OFFSET $${
      params.length + 2
    }`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    // Get total count
    let countQuery = `
      SELECT COUNT(*)
      FROM drives d
      WHERE 1=1
    `;

    const countParams = [];

    if (status) {
      countParams.push(status);
      countQuery += ` AND d.status = $${countParams.length}`;
    }

    if (date) {
      countParams.push(`${date}%`);
      countQuery += ` AND CAST(d.created_at AS TEXT) LIKE $${countParams.length}`;
    }

    if (delivery_guy_id) {
      countParams.push(delivery_guy_id);
      countQuery += ` AND d.delivery_guy_id = $${countParams.length}`;
    }

    if (route_id) {
      countParams.push(route_id);
      countQuery += ` AND d.route_id = $${countParams.length}`;
    }

    const countResult = await pool.query(countQuery, countParams);
    const totalCount = parseInt(countResult.rows[0].count);

    res.json({
      drives: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        totalCount,
        totalPages: Math.ceil(totalCount / limit)
      }
    });
  } catch (error) {
    console.error("Get drives error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDriveById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT d.*, r.name as route_name, dg.name as delivery_guy_name
       FROM drives d
       LEFT JOIN routes r ON d.route_id = r.route_id
       LEFT JOIN delivery_guys dg ON d.delivery_guy_id = dg.delivery_guy_id
       WHERE d.drive_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    res.json({ drive: result.rows[0] });
  } catch (error) {
    console.error("Get drive by ID error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const createDrive = async (req, res) => {
  try {
    const {
      route_id,
      delivery_guy_id,
      stock,
      remarks,
      name,
      start_time
    } = req.body;

    // Basic validation
    if (!route_id || !stock) {
      return res
        .status(400)
        .json({ message: "Route ID and stock are required" });
    }

    // Check if route exists
    const routeCheck = await pool.query(
      "SELECT route_id FROM routes WHERE route_id = $1",
      [route_id]
    );

    if (routeCheck.rows.length === 0) {
      return res.status(404).json({ message: "Route not found" });
    }

    // Check if delivery guy exists (if provided)
    if (delivery_guy_id) {
      const deliveryGuyCheck = await pool.query(
        "SELECT delivery_guy_id FROM delivery_guys WHERE delivery_guy_id = $1",
        [delivery_guy_id]
      );

      if (deliveryGuyCheck.rows.length === 0) {
        return res.status(404).json({ message: "Delivery person not found" });
      }
    }

    // Create drive
    const result = await pool.query(
      `INSERT INTO drives (route_id, delivery_guy_id, stock, remarks, status,name)
       VALUES ($1, $2, $3, $4, 'pending' , $5)
       RETURNING *`,
      [
        route_id,
        delivery_guy_id || null,
        stock,
        remarks || null,
        name
      ]
    );

    res.status(201).json({
      message: "Drive created successfully",
      drive: result.rows[0]
    });
  } catch (error) {
    console.error("Create drive error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const updateDrive = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      route_id,
      delivery_guy_id,
      stock,
      sold,
      returned,
      remarks,
      status,
      name
    } = req.body;

    // Check if drive exists
    const driveCheck = await pool.query(
      "SELECT * FROM drives WHERE drive_id = $1",
      [id]
    );

    if (driveCheck.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    const currentDrive = driveCheck.rows[0];

    // Can't modify certain fields if drive is already started or completed
    if (currentDrive.status !== "pending" && (route_id || stock)) {
      return res.status(400).json({
        message:
          "Cannot modify route or stock for a drive that has already started"
      });
    }

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramCounter = 1;

    if (route_id) {
      // Check if route exists
      const routeCheck = await pool.query(
        "SELECT route_id FROM routes WHERE route_id = $1",
        [route_id]
      );

      if (routeCheck.rows.length === 0) {
        return res.status(404).json({ message: "Route not found" });
      }

      updates.push(`route_id = $${paramCounter++}`);
      values.push(route_id);
    }

    if (delivery_guy_id) {
      // Check if delivery guy exists
      const deliveryGuyCheck = await pool.query(
        "SELECT delivery_guy_id FROM delivery_guys WHERE delivery_guy_id = $1",
        [delivery_guy_id]
      );

      if (deliveryGuyCheck.rows.length === 0) {
        return res.status(404).json({ message: "Delivery person not found" });
      }

      updates.push(`delivery_guy_id = $${paramCounter++}`);
      values.push(delivery_guy_id);
    } else if (delivery_guy_id === null) {
      updates.push(`delivery_guy_id = NULL`);
    }

    if (stock !== undefined) {
      updates.push(`stock = $${paramCounter++}`);
      values.push(stock);
    }

    if (sold !== undefined) {
      updates.push(`sold = $${paramCounter++}`);
      values.push(sold);
    }

    if (returned !== undefined) {
      updates.push(`returned = $${paramCounter++}`);
      values.push(returned);
    }

    if (remarks !== undefined) {
      updates.push(`remarks = $${paramCounter++}`);
      values.push(remarks);
    }

    if (status) {
      updates.push(`status = $${paramCounter++}`);
      values.push(status);
    }

    if (name) {
      updates.push(`name = $${paramCounter++}`);
      values.push(name);
    }

    updates.push(`updated_at = $${paramCounter++}`);
    values.push(new Date());

    if (updates.length === 1) {
      // Only updated_at was added
      return res
        .status(400)
        .json({ message: "No valid fields provided for update" });
    }

    // Add drive ID to values array
    values.push(id);

    const result = await pool.query(
      `UPDATE drives
       SET ${updates.join(", ")}
       WHERE drive_id = $${paramCounter}
       RETURNING *`,
      values
    );

    res.json({
      message: "Drive updated successfully",
      drive: result.rows[0]
    });
  } catch (error) {
    console.error("Update drive error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const deleteDrive = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if drive exists
    const driveCheck = await pool.query(
      "SELECT status FROM drives WHERE drive_id = $1",
      [id]
    );

    if (driveCheck.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    // Check if drive can be deleted (only pending drives can be deleted)
    if (driveCheck.rows[0].status !== "pending") {
      return res.status(400).json({
        message:
          "Only pending drives can be deleted. Completed or ongoing drives cannot be deleted."
      });
    }

    await pool.query("DELETE FROM drives WHERE drive_id = $1", [id]);

    res.json({ message: "Drive deleted successfully" });
  } catch (error) {
    console.error("Delete drive error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDriveDetails = async (req, res) => {
  try {
    const { id } = req.params;

    // Get drive details
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

    // Get customers in the route
    const customersResult = await pool.query(
      `SELECT c.*,
        COALESCE(dcs.quantity, 0) as delivered_quantity,
        COALESCE(dcs.status, 'pending') as delivery_status
       FROM customers c
       JOIN route_customers rc ON c.customer_id = rc.customer_id
       LEFT JOIN drive_customers_sales dcs ON c.customer_id = dcs.customer_id AND dcs.drive_id = $1
       WHERE rc.route_id = $2
       ORDER BY c.name`,
      [id, drive.route_id]
    );

    res.json({
      drive,
      customers: customersResult.rows,
      customerCount: customersResult.rows.length
    });
  } catch (error) {
    console.error("Get drive details error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const assignDeliveryPersonToDrive = async (req, res) => {
  try {
    const { id } = req.params;
    const { delivery_guy_id } = req.body;

    if (!delivery_guy_id) {
      return res
        .status(400)
        .json({ message: "Delivery person ID is required" });
    }

    // Check if drive exists
    const driveCheck = await pool.query(
      "SELECT * FROM drives WHERE drive_id = $1",
      [id]
    );

    if (driveCheck.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    // Check if the drive is in a state where assignment is allowed
    if (driveCheck.rows[0].status !== "pending") {
      return res.status(400).json({
        message:
          "Cannot assign delivery person to a drive that has already started or completed"
      });
    }

    // Check if delivery guy exists
    const deliveryGuyCheck = await pool.query(
      "SELECT delivery_guy_id FROM delivery_guys WHERE delivery_guy_id = $1",
      [delivery_guy_id]
    );

    if (deliveryGuyCheck.rows.length === 0) {
      return res.status(404).json({ message: "Delivery person not found" });
    }

    // Assign delivery person to drive
    const result = await pool.query(
      `UPDATE drives
       SET delivery_guy_id = $1, updated_at = NOW()
       WHERE drive_id = $2
       RETURNING *`,
      [delivery_guy_id, id]
    );

    res.json({
      message: "Delivery person assigned to drive successfully",
      drive: result.rows[0]
    });
  } catch (error) {
    console.error("Assign delivery person error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const startDrive = async (req, res) => {
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

    // Check if drive can be started
    if (driveCheck.rows[0].status !== "pending") {
      return res
        .status(400)
        .json({ message: "Drive is already started or completed" });
    }

    // Check if delivery guy is assigned
    if (!driveCheck.rows[0].delivery_guy_id) {
      return res.status(400).json({
        message: "Cannot start drive without assigned delivery person"
      });
    }

    // Start drive
    const result = await pool.query(
      `UPDATE drives
       SET status = 'ongoing', start_time = NOW(), updated_at = NOW()
       WHERE drive_id = $1
       RETURNING *`,
      [id]
    );

    res.json({
      message: "Drive started successfully",
      drive: result.rows[0]
    });
  } catch (error) {
    console.error("Start drive error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const endDrive = async (req, res) => {
  try {
    const { id } = req.params;
    const { sold, returned, remarks } = req.body;

    // Check if drive exists
    const driveCheck = await pool.query(
      "SELECT * FROM drives WHERE drive_id = $1",
      [id]
    );

    if (driveCheck.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    // Check if drive can be ended
    if (driveCheck.rows[0].status !== "ongoing") {
      return res
        .status(400)
        .json({ message: "Only ongoing drives can be ended" });
    }

    // Calculate total amount from sales
    const salesResult = await pool.query(
      "SELECT SUM(total_amount) as totalSales FROM drive_customers_sales WHERE drive_id = $1",
      [id]
    );

    const total_amount = salesResult.rows[0].totalsales || 0;

    // End drive
    const result = await pool.query(
      `UPDATE drives
       SET status = 'completed', end_time = NOW(), sold = $1, returned = $2,
           remarks = $3, total_amount = $4, updated_at = NOW()
       WHERE drive_id = $5
       RETURNING *`,
      [sold || 0, returned || 0, remarks || null, total_amount, id]
    );

    res.json({
      message: "Drive ended successfully",
      drive: result.rows[0]
    });
  } catch (error) {
    console.error("End drive error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDriveLocations = async (req, res) => {
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

    // Get location logs
    const result = await pool.query(
      `SELECT drive_location_id,
              longitude,
              latitude,
              time
       FROM drive_locations_log
       WHERE drive_id = $1
       ORDER BY time`,
      [id]
    );

    res.json({
      drive_id: parseInt(id),
      locations: result.rows
    });
  } catch (error) {
    console.error("Get drive locations error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const logDriveLocation = async (req, res) => {
console.log(req)

  try {
    const { id } = req.params;
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res
        .status(400)
        .json({ message: "Latitude and longitude are required" });
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
      return res
        .status(400)
        .json({ message: "Can only log locations for ongoing drives" });
    }

    // Log location
    const result = await pool.query(
      `INSERT INTO drive_locations_log (drive_id,  longitude, latitude, time)
       VALUES ($1, $2, $3, NOW())
       RETURNING drive_location_id,
                 longitude,
                 latitude,
                 time`,
      [id, longitude, latitude]
    );

    res.status(201).json({
      message: "Location logged successfully",
      location: result.rows[0]
    });
  } catch (error) {
    console.error("Log drive location error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDriveSummary = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if drive exists
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

    // Get sales summary
    const salesResult = await pool.query(
      `SELECT COUNT(*) as total_customers,
              SUM(quantity) as totalQuantity,
              SUM(total_amount) as total_amount,
              COUNT(CASE WHEN status = 'success' THEN 1 END) as successful_deliveries,
              COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_deliveries
       FROM drive_customers_sales
       WHERE drive_id = $1`,
      [id]
    );

    // Get route customers count
    const routeCustomersResult = await pool.query(
      `SELECT COUNT(*) as totalRouteCustomers
       FROM route_customers
       WHERE route_id = $1`,
      [drive.route_id]
    );

    const summary = {
      ...salesResult.rows[0],
      totalRouteCustomers: routeCustomersResult.rows[0].totalroutecustomers,
      deliveryRate:
        salesResult.rows[0].totalcustomers > 0
          ? (salesResult.rows[0].successfuldeliveries /
              salesResult.rows[0].totalcustomers) *
            100
          : 0,
      returnRate: drive.stock > 0 ? (drive.returned / drive.stock) * 100 : 0
    };

    res.json({
      drive,
      summary
    });
  } catch (error) {
    console.error("Get drive summary error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDriveManifest = async (req, res) => {
  try {
    const { id } = req.params;

    // Get drive details
    const driveResult = await pool.query(
      `SELECT d.*, r.name as route_name, dg.name as delivery_guy_name
       FROM drives d
       LEFT JOIN routes r ON d.route_id = r.route_id
       LEFT JOIN delivery_guys dg ON d.delivery_guy_id = dg.delivery_guy_id
       WHERE d.drive_id = $1`,
      [id]
    );
console.log(1);


    if (driveResult.rows.length === 0) {
      return res.status(404).json({ message: "Drive not found" });
    }

    const drive = driveResult.rows[0];

console.log(2);

    // Get customers in the route with their details
    const customersResult = await pool.query(
      `SELECT *
       FROM customers c
       JOIN route_customers rc ON c.customer_id = rc.customer_id
       WHERE rc.route_id = $1 AND c.status = 'active'
       ORDER BY c.name`,
      [drive.route_id]
    );
console.log(3);

    res.json({
      drive: {
        drive_id: drive.driveid,
        date: drive.created_at,
        route_name: drive.routename,
        deliveryPerson: drive.deliveryguyname,
        stock: drive.stock
      },
      customers: customersResult.rows,
      customerCount: customersResult.rows.length,
      totalExpectedQuantity: customersResult.rows.reduce(
        (sum, customer) => sum + customer.defaultquantity,
        0
      )
    });
  } catch (error) {
    console.error("Get drive manifest error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
