import pool from "../config/database.js";

export const getCustomers = async (req, res) => {
  try {
    // Get pagination parameters from query
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // Get filter parameters
    const { name, location, status } = req.query;

    // Initialize query and parameters
    let query = "SELECT * FROM customers WHERE 1=1";
    const params = [];

    // Apply filters if provided
    if (name) {
      params.push(`%${name}%`);
      query += ` AND name LIKE $${params.length}`;
    }

    if (location) {
      params.push(`%${location}%`);
      query += ` AND location LIKE $${params.length}`;
    }

    if (status) {
      params.push(status);
      query += ` AND status = $${params.length}`;
    }

    // If admin user, filter by their outlet_id
    if (req.user.role === "admin" && req.user.outlet_id) {
      // Add outlet filter to query
      query += " AND outlet_id = $" + params.length + 1;
      params.push(req.user.outlet_id);
    }

    // Add pagination
    query += ` ORDER BY name LIMIT $${params.length + 1} OFFSET $${
      params.length + 2
    }`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "No customers found" });
    }

    // Get total count for pagination
    const countResult = await pool.query(
      `SELECT COUNT(*) FROM customers WHERE 1=1${
        name ? " AND name LIKE $1" : ""
      }${location ? ` AND location LIKE $${name ? 2 : 1}` : ""}${
        status
          ? ` AND status = $${(name ? 1 : 0) + (location ? 1 : 0) + 1}`
          : ""
      }`,
      [
        ...(name ? [`%${name}%`] : []),
        ...(location ? [`%${location}%`] : []),
        ...(status ? [status] : [])
      ]
    );

    const totalCount = parseInt(countResult.rows[0].count);

    // Fetch Extra data for each customer like: QR, photo URL, transactions
    const customers = await Promise.all(
      result.rows.map(async (customer) => {
        const qrResult = await pool.query(
          "SELECT * FROM qr_codes WHERE customer_id = $1",
          [customer.customer_id]
        );

        // Add full photo URL if exists
        if (customer.photo) {
          customer.photo_url = `${req.protocol}://${req.get("host")}/${
            customer.photo
          }`;
        }

        // Fetch transactions for this customer
        const transactionResult = await pool.query(
          "SELECT * FROM point_transactions WHERE customer_id = $1 ORDER BY created_at DESC",
          [customer.customer_id]
        );
        customer.transactions = transactionResult.rows;

        return {
          ...customer,
          qr: qrResult.rows.length > 0 ? qrResult.rows[0] : null
        };
      })
    );

    res.json({
      customers,
      pagination: {
        page,
        limit,
        totalCount,
        totalPages: Math.ceil(totalCount / limit)
      }
    });
  } catch (error) {
    console.error("Get customers error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getCustomerById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      "SELECT * FROM customers WHERE customer_id = $1",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    // Fetch and add qr code related data to customer
    const qrResult = await pool.query(
      "SELECT * FROM qr_codes WHERE customer_id = $1",
      [id]
    );
    const qrCode = qrResult.rows.length > 0 ? qrResult.rows[0] : null;
    const customer = result.rows[0];
    customer.qr = qrCode;
    // Add full photo URL if exists
    if (customer.photo) {
      customer.photo_url = `${req.protocol}://${req.get("host")}/${
        customer.photo
      }`;
    }

    // Add transaction logs
    const transactionResult = await pool.query(
      "SELECT * FROM point_transactions WHERE customer_id = $1 ORDER BY created_at DESC",
      [id]
    );
    customer.transactions = transactionResult.rows;

    res.json({ customer: customer });
  } catch (error) {
    console.error("Get customer by ID error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
export const createCustomer = async (req, res) => {
  try {
    const { name, location, phone, address, stop_loss, default_quantity } =
      req.body;

    // Basic validation
    if (!name || !phone) {
      // Clean up uploaded file if validation fails
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }

      return res.status(400).json({ message: "Name, phone are required" });
    }

    // Check if phone already exists
    const checkResult = await pool.query(
      "SELECT customer_id FROM customers WHERE phone = $1",
      [phone]
    );

    if (checkResult.rows.length > 0) {
      // Clean up uploaded file if customer already exists
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res
        .status(400)
        .json({ message: "Customer with this phone number already exists" });
    }

    // Handle photo upload
    let photoPath = null;
    if (req.file) {
      // Store relative path for database
      photoPath = req.file.path.replace(/\\/g, "/"); // Normalize path separators
    }

    const result = await pool.query(
      `INSERT INTO customers (name, location, phone, address, stop_loss, default_quantity, photo)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        name,
        location,
        phone,
        address,
        stop_loss,
        default_quantity || 1,
        photoPath
      ]
    );

    const customer = result.rows[0];

    // Add full photo URL to response
    if (customer.photo) {
      customer.photo_url = `${req.protocol}://${req.get("host")}/${
        customer.photo
      }`;
    }

    res.status(201).json({
      message: "Customer created successfully",
      customer: customer
    });
  } catch (error) {
    console.error("Create customer error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const updateCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      location,
      phone,
      address,
      stop_loss,
      default_quantity,
      status
    } = req.body;

    // Check if customer exists
    const checkResult = await pool.query(
      "SELECT customer_id FROM customers WHERE customer_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }

      return res.status(404).json({ message: "Customer not found" });
    }

    // Check if phone is being changed and if so, if it's already in use
    if (phone) {
      const phoneCheckResult = await pool.query(
        "SELECT customer_id FROM customers WHERE phone = $1 AND customer_id != $2",
        [phone, id]
      );

      if (phoneCheckResult.rows.length > 0) {
        return res.status(400).json({ message: "Phone number already in use" });
      }
    }

    // Handle photo update
    let photoPath = checkResult.rows[0].photo; // Keep existing photo by default

    if (req.file) {
      // Delete old photo if it exists
      if (checkResult.rows[0].photo) {
        try {
          fs.unlinkSync(existingCustomer.rows[0].photo);
        } catch (error) {
          console.log("Old photo file not found or already deleted");
        }
      }

      // Set new photo path
      photoPath = req.file.path.replace(/\\/g, "/");
    }

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramCounter = 1;

    if (name) {
      updates.push(`name = $${paramCounter++}`);
      values.push(name);
    }

    if (location !== undefined) {
      updates.push(`location = $${paramCounter++}`);
      values.push(location);
    }

    if (phone) {
      updates.push(`phone = $${paramCounter++}`);
      values.push(phone);
    }

    if (address !== undefined) {
      updates.push(`address = $${paramCounter++}`);
      values.push(address);
    }

    if (stop_loss !== undefined) {
      updates.push(`stop_loss = $${paramCounter++}`);
      values.push(stop_loss);
    }

    if (default_quantity !== undefined) {
      updates.push(`default_quantity = $${paramCounter++}`);
      values.push(default_quantity);
    }

    if (status) {
      updates.push(`status = $${paramCounter++}`);
      values.push(status);
    }

    if (photoPath) {
      updates.push(`photo = $${paramCounter++}`);
      values.push(photoPath);
    }

    updates.push(`updated_at = $${paramCounter++}`);
    values.push(new Date());

    if (updates.length === 1) {
      // Only updated_at was added
      return res
        .status(400)
        .json({ message: "No valid fields provided for update" });
    }

    // Add customer ID to values array
    values.push(id);

    const result = await pool.query(
      `UPDATE customers
       SET ${updates.join(", ")}
       WHERE customer_id = $${paramCounter}
       RETURNING *`,
      values
    );

    const customer = result.rows[0];

    // Add full photo URL to response
    if (customer.photo) {
      customer.photo_url = `${req.protocol}://${req.get("host")}/${
        customer.photo
      }`;
    }

    res.json({
      message: "Customer updated successfully",
      customer: customer
    });
  } catch (error) {
    console.error("Update customer error:", error);

    if (req.file) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (unlinkError) {
        console.error("Error deleting uploaded file:", unlinkError);
      }
    }

    res.status(500).json({ message: "Server error" });
  }
};

export const deleteCustomer = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if customer exists
    const checkResult = await pool.query(
      "SELECT customer_id FROM customers WHERE customer_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    // Delete customer
    await pool.query("DELETE FROM customers WHERE customer_id = $1", [id]);

    res.json({ message: "Customer deleted successfully" });
  } catch (error) {
    console.error("Delete customer error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getCustomerPoints = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      "SELECT customer_id, points FROM customers WHERE customer_id = $1",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    res.json({ points: result.rows[0].points });
  } catch (error) {
    console.error("Get customer points error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const addCustomerPoints = async (req, res) => {
  try {
    const { id } = req.params;
    const { points } = req.body;

    if (!points) {
      return res
        .status(400)
        .json({ message: "Valid points value is required" });
    }

    /*   const result = await pool.query(
      "UPDATE customers SET points = points + $1 WHERE customer_id = $2 RETURNING customer_id, points",
      [points, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    res.json({
      message: "Points added successfully",
      points: result.rows[0].points
    });
    */

    // Get current points
    const checkResult = await pool.query(
      "SELECT points FROM customers WHERE customer_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    const currentPoints = checkResult.rows[0].points;

    // Start transaction
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // Update customer points
      const result = await client.query(
        "UPDATE customers SET points = points + $1 WHERE customer_id = $2 RETURNING customer_id, points",
        [points, id]
      );

      const newBalance = result.rows[0].points;

      // Log the transaction
      await client.query(
        `INSERT INTO point_transactions
         (customer_id, transaction_type, points, previous_balance, new_balance, performed_by)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [id, "credit", points, currentPoints, newBalance, req.user.user_id]
      );

      await client.query("COMMIT");

      res.json({
        message: "Points added successfully",
        points: newBalance,
        transaction: {
          added: points,
          previous_balance: currentPoints,
          new_balance: newBalance
        }
      });
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Add customer points error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const deductCustomerPoints = async (req, res) => {
  try {
    const { id } = req.params;
    const { points } = req.body;

    if (!points || points <= 0) {
      return res
        .status(400)
        .json({ message: "Valid points value is required" });
    }

    // Check if customer has sufficient points and get stop_loss
    const checkResult = await pool.query(
      "SELECT points, stop_loss FROM customers WHERE customer_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    const currentPoints = parseInt(checkResult.rows[0].points);
    const stopLoss = parseInt(checkResult.rows[0].stop_loss);

    // Check if customer has stop_loss and if current points would go below stop_loss after deduction
    if (
      stopLoss !== null &&
      stopLoss !== undefined &&
      currentPoints - points > stopLoss
    ) {
      return res.status(400).json({
        message: `Cannot deduct points. Points would go below stop loss limit of ${stopLoss}`
      });
    }

    /*  // Update points
    const result = await pool.query(
      "UPDATE customers SET points = points - $1 WHERE customer_id = $2 RETURNING customer_id, points",
      [points, id]
    ); */

    console.log(req.user);

    // Start transaction
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // Update customer points
      const result = await client.query(
        "UPDATE customers SET points = points - $1 WHERE customer_id = $2 RETURNING customer_id, points",
        [points, id]
      );

      const newBalance = result.rows[0].points;

      // Log the transaction
      await client.query(
        `INSERT INTO point_transactions
         (customer_id, transaction_type, points, previous_balance, new_balance, performed_by)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          id,
          "debit",
          points,
          currentPoints,
          newBalance,
          // reason || "Manual deduction",
          req.user.user_id
        ]
      );

      await client.query("COMMIT");

      res.json({
        message: "Points deducted successfully",
        points: newBalance,
        transaction: {
          deducted: points,
          previous_balance: currentPoints,
          new_balance: newBalance
        }
      });
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Deduct customer points error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getCustomerPaymentLogs = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if customer exists
    const checkResult = await pool.query(
      "SELECT customer_id FROM customers WHERE customer_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    // Get pagination parameters
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const result = await pool.query(
      "SELECT * FROM payment_logs WHERE customer_id = $1 ORDER BY date DESC LIMIT $2 OFFSET $3",
      [id, limit, offset]
    );

    const countResult = await pool.query(
      "SELECT COUNT(*) FROM payment_logs WHERE customer_id = $1",
      [id]
    );

    const totalCount = parseInt(countResult.rows[0].count);

    res.json({
      paymentLogs: result.rows,
      pagination: {
        page,
        limit,
        totalCount,
        totalPages: Math.ceil(totalCount / limit)
      }
    });
  } catch (error) {
    console.error("Get customer payment logs error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getCustomerRoutes = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if customer exists
    const checkResult = await pool.query(
      "SELECT customer_id FROM customers WHERE customer_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    // Get pagination parameters
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // Query to get all routes with this customer
    const result = await pool.query(
      `SELECT r.route_id, r.name, r.created_at
       FROM routes r
       JOIN route_customers rc ON r.route_id = rc.route_id
       WHERE rc.customer_id = $1
       ORDER BY r.name
       LIMIT $2 OFFSET $3`,
      [id, limit, offset]
    );

    // Get total count for pagination
    const countResult = await pool.query(
      `SELECT COUNT(DISTINCT r.route_id)
       FROM routes r
       JOIN route_customers rc ON r.route_id = rc.route_id
       WHERE rc.customer_id = $1`,
      [id]
    );

    const totalCount = parseInt(countResult.rows[0].count);

    res.json({
      routes: result.rows,
      pagination: {
        page,
        limit,
        totalCount,
        totalPages: Math.ceil(totalCount / limit)
      }
    });
  } catch (error) {
    console.error("Get customer routes error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// All Transaction Combined
export const getCustomerTransactions = async (req, res) => {
  try {
    // const { id } = req.params;

    // Check if customer exists
    // const checkResult = await pool.query("SELECT customer_id FROM customers");

    // if (checkResult.rows.length === 0) {
    //   return res.status(404).json({ message: "Customer not found" });
    // }

    // Get pagination parameters
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // Query to get all transactions for this customer
    const result = await pool.query(
      `SELECT pt.*, c.name AS customer_name, c.phone AS customer_phone
       FROM point_transactions pt
       JOIN customers c ON pt.customer_id = c.customer_id
       ORDER BY pt.created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );

    console.log("Transactions Result:", result.rows);


    // Get total count for pagination
    const countResult = await pool.query(
      `SELECT COUNT(*) FROM point_transactions`
    );

    const totalCount = parseInt(countResult.rows[0].count);

    res.json({
      transactions: result.rows,
      pagination: {
        page,
        limit,
        totalCount,
        totalPages: Math.ceil(totalCount / limit)
      }
    });
  } catch (error) {
    console.error("Get customer transactions error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
