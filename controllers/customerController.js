import pool from "../config/database.js";

export const getCustomers = async (req, res) => {
  try {
    // Get pagination parameters from query
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // Get filter parameters
    const { name, location, status } = req.query;

    let query = "SELECT * FROM customers WHERE 1=1";
    const params = [];

    // Apply filters if provided
    if (name) {
      params.push(`%${name}%`);
      query += ` AND name ILIKE $${params.length}`;
    }

    if (location) {
      params.push(`%${location}%`);
      query += ` AND location ILIKE $${params.length}`;
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

    // Get total count for pagination
    const countResult = await pool.query(
      `SELECT COUNT(*) FROM customers WHERE 1=1${
        name ? " AND name ILIKE $1" : ""
      }${location ? ` AND location ILIKE $${name ? 2 : 1}` : ""}${
        status
          ? ` AND status = $${(name ? 1 : 0) + (location ? 1 : 0) + 1}`
          : ""
      }`,
      [
        ...(name ? [`%${name}%`] : []),
        ...(location ? [`%${location}%`] : []),
        ...(status ? [status] : []),
      ]
    );

    const totalCount = parseInt(countResult.rows[0].count);

    res.json({
      customers: result.rows,
      pagination: {
        page,
        limit,
        totalCount,
        totalPages: Math.ceil(totalCount / limit),
      },
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

    res.json({ customer: result.rows[0] });
  } catch (error) {
    console.error("Get customer by ID error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const createCustomer = async (req, res) => {
  try {
    const { name, location, phone, address, price, default_quantity } = req.body;

    // Basic validation
    if (!name || !phone || !price) {
      return res
        .status(400)
        .json({ message: "Name, phone, and price are required" });
    }

    // Check if phone already exists
    const checkResult = await pool.query(
      "SELECT customer_id FROM customers WHERE phone = $1",
      [phone]
    );

    if (checkResult.rows.length > 0) {
      return res.status(400).json({ message: "Phone number already in use" });
    }

    const result = await pool.query(
      `INSERT INTO customers (name, location, phone, address, price, default_quantity)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [name, location, phone, address, price, default_quantity || 1]
    );

    res.status(201).json({
      message: "Customer created successfully",
      customer: result.rows[0],
    });
  } catch (error) {
    console.error("Create customer error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const updateCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, location, phone, address, price, default_quantity, status } =
      req.body;

    // Check if customer exists
    const checkResult = await pool.query(
      "SELECT customer_id FROM customers WHERE customer_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
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

    if (price !== undefined) {
      updates.push(`price = $${paramCounter++}`);
      values.push(price);
    }

    if (default_quantity !== undefined) {
      updates.push(`default_quantity = $${paramCounter++}`);
      values.push(default_quantity);
    }

    if (status) {
      updates.push(`status = $${paramCounter++}`);
      values.push(status);
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

    res.json({
      message: "Customer updated successfully",
      customer: result.rows[0],
    });
  } catch (error) {
    console.error("Update customer error:", error);
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

    if (!points || points <= 0) {
      return res
        .status(400)
        .json({ message: "Valid points value is required" });
    }

    const result = await pool.query(
      "UPDATE customers SET points = points + $1 WHERE customer_id = $2 RETURNING customer_id, points",
      [points, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    res.json({
      message: "Points added successfully",
      points: result.rows[0].points,
    });
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

    // Check if customer has sufficient points
    const checkResult = await pool.query(
      "SELECT points FROM customers WHERE customer_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    const currentPoints = checkResult.rows[0].points;

    if (currentPoints < points) {
      return res.status(400).json({ message: "Insufficient points" });
    }

    const result = await pool.query(
      "UPDATE customers SET points = points - $1 WHERE customer_id = $2 RETURNING customer_id, points",
      [points, id]
    );

    res.json({
      message: "Points deducted successfully",
      points: result.rows[0].points,
    });
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
        totalPages: Math.ceil(totalCount / limit),
      },
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
        totalPages: Math.ceil(totalCount / limit),
      },
    });
  } catch (error) {
    console.error("Get customer routes error:", error);
    res.status(500).json({ message: "Server error" });
  }
};