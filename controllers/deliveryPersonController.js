import pool from "../config/database.js";
import bcrypt from "bcrypt";

export const getDeliveryPersons = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT d.*,
              (SELECT COUNT(*) FROM users u WHERE u.delivery_guy_id = d.delivery_guy_id) as hasAccount
       FROM delivery_guys d
       ORDER BY d.name`
    );

    res.json({
      deliveryPersons: result.rows,
    });
  } catch (error) {
    console.error("Get delivery persons error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDeliveryPersonById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT d.*,
              (SELECT u.user_id FROM users u WHERE u.delivery_guy_id = d.delivery_guy_id) as user_id,
              (SELECT u.phone FROM users u WHERE u.delivery_guy_id = d.delivery_guy_id) as userPhone
       FROM delivery_guys d
       WHERE d.delivery_guy_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Delivery person not found" });
    }

    res.json({
      deliveryPerson: result.rows[0],
    });
  } catch (error) {
    console.error("Get delivery person by ID error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// export const createDeliveryPerson = async (req, res) => {
//   try {
//     const { name, phone, address } = req.body;

//     // Basic validation
//     if (!name || !phone) {
//       return res.status(400).json({ message: "Name and phone are required" });
//     }

//     // Check if phone already exists
//     const phoneCheck = await pool.query(
//       "SELECT delivery_guy_id FROM delivery_guys WHERE phone = $1",
//       [phone]
//     );

//     if (phoneCheck.rows.length > 0) {
//       return res.status(400).json({ message: "Phone number already in use" });
//     }

//     // Create delivery person
//     const result = await pool.query(
//       `INSERT INTO delivery_guys (name, phone, address)
//        VALUES ($1, $2, $3)
//        RETURNING *`,
//       [name, phone, address || null]
//     );

//     res.status(201).json({
//       message: "Delivery person created successfully",
//       deliveryPerson: result.rows[0],
//     });
//   } catch (error) {
//     console.error("Create delivery person error:", error);
//     res.status(500).json({ message: "Server error" });
//   }
// };



export const createDeliveryPerson = async (req, res) => {
  try {
    const { name, phone, address, password, createUserAccount = true } = req.body;

    // Basic validation
    if (!name || !phone) {
      return res.status(400).json({ message: "Name and phone are required" });
    }

    if (createUserAccount && !password) {
      return res.status(400).json({
        message: "Password is required when creating user account"
      });
    }

    // Check if phone already exists in delivery_guys
    const phoneCheck = await pool.query(
      "SELECT delivery_guy_id FROM delivery_guys WHERE phone = $1",
      [phone]
    );

    if (phoneCheck.rows.length > 0) {
      return res.status(400).json({ message: "Phone number already in use" });
    }

    // Check if phone already exists in users (if creating user account)
    if (createUserAccount) {
      const userPhoneCheck = await pool.query(
        "SELECT user_id FROM users WHERE phone = $1",
        [phone]
      );

      if (userPhoneCheck.rows.length > 0) {
        return res.status(400).json({
          message: "Phone number already exists as a user account"
        });
      }
    }

    // Start transaction
    await pool.query('BEGIN');

    try {
      // Create delivery person
      const deliveryPersonResult = await pool.query(
        `INSERT INTO delivery_guys (name, phone, address)
         VALUES ($1, $2, $3)
         RETURNING *`,
        [name, phone, address || null]
      );

      const deliveryPerson = deliveryPersonResult.rows[0];
      let userAccount = null;

      // Create user account if requested
      if (createUserAccount) {
        const hashedPassword = await bcrypt.hash(password, 10);

        const userResult = await pool.query(
          `INSERT INTO users (phone, password, role, delivery_guy_id)
           VALUES ($1, $2, $3, $4)
           RETURNING user_id, phone, role, delivery_guy_id, created_at`,
          [phone, hashedPassword, 'delivery_guy', deliveryPerson.delivery_guy_id]
        );

        userAccount = userResult.rows[0];
      }

      // Commit transaction
      await pool.query('COMMIT');

      res.status(201).json({
        message: createUserAccount
          ? "Delivery person and user account created successfully"
          : "Delivery person created successfully",
        deliveryPerson,
        userAccount,
        hasUserAccount: createUserAccount
      });

    } catch (transactionError) {
      // Rollback transaction on error
      await pool.query('ROLLBACK');
      throw transactionError;
    }

  } catch (error) {
    console.error("Create delivery person error:", error);
    res.status(500).json({ message: "Server error" });
  }
};


export const updateDeliveryPerson = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, phone, address } = req.body;

    // Check if delivery person exists
    const checkResult = await pool.query(
      "SELECT delivery_guy_id FROM delivery_guys WHERE delivery_guy_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Delivery person not found" });
    }

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramCounter = 1;

    if (name) {
      updates.push(`name = $${paramCounter++}`);
      values.push(name);
    }

    if (phone) {
      // Check if phone already exists for another delivery person
      const phoneCheck = await pool.query(
        "SELECT delivery_guy_id FROM delivery_guys WHERE phone = $1 AND delivery_guy_id != $2",
        [phone, id]
      );

      if (phoneCheck.rows.length > 0) {
        return res.status(400).json({ message: "Phone number already in use" });
      }

      updates.push(`phone = $${paramCounter++}`);
      values.push(phone);
    }

    if (address !== undefined) {
      updates.push(`address = $${paramCounter++}`);
      values.push(address);
    }

    updates.push(`updated_at = $${paramCounter++}`);
    values.push(new Date());

    if (updates.length === 1) {
      // Only updated_at was added
      return res
        .status(400)
        .json({ message: "No valid fields provided for update" });
    }

    // Add delivery person ID to values array
    values.push(id);

    const result = await pool.query(
      `UPDATE delivery_guys
       SET ${updates.join(", ")}
       WHERE delivery_guy_id = $${paramCounter}
       RETURNING *`,
      values
    );

    res.json({
      message: "Delivery person updated successfully",
      deliveryPerson: result.rows[0],
    });
  } catch (error) {
    console.error("Update delivery person error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const deleteDeliveryPerson = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if delivery person exists
    const checkResult = await pool.query(
      "SELECT delivery_guy_id FROM delivery_guys WHERE delivery_guy_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Delivery person not found" });
    }

    // Check if delivery person has a user account
    const userCheck = await pool.query(
      "SELECT user_id FROM users WHERE delivery_guy_id = $1",
      [id]
    );

    if (userCheck.rows.length > 0) {
      return res.status(400).json({
        message:
          "Cannot delete delivery person with an active user account. Delete the user account first.",
      });
    }

    // Check if delivery person has associated drives
    const driveCheck = await pool.query(
      "SELECT drive_id FROM drives WHERE delivery_guy_id = $1",
      [id]
    );

    if (driveCheck.rows.length > 0) {
      return res.status(400).json({
        message: "Cannot delete delivery person with associated drives.",
      });
    }

    // Delete delivery person
    await pool.query("DELETE FROM delivery_guys WHERE delivery_guy_id = $1", [
      id,
    ]);

    res.json({ message: "Delivery person deleted successfully" });
  } catch (error) {
    console.error("Delete delivery person error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDeliveryPersonDrives = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, fromDate, toDate, page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;

    // Check if delivery person exists
    const checkResult = await pool.query(
      "SELECT delivery_guy_id FROM delivery_guys WHERE delivery_guy_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Delivery person not found" });
    }

    // Build query
    let query = `
      SELECT d.*, r.name as route_name
      FROM drives d
      LEFT JOIN routes r ON d.route_id = r.route_id
      WHERE d.delivery_guy_id = $1
    `;

    const params = [id];
    let paramIndex = 2;

    if (status) {
      query += ` AND d.status = $${paramIndex++}`;
      params.push(status);
    }

    if (fromDate) {
      query += ` AND d.created_at >= $${paramIndex++}`;
      params.push(fromDate);
    }

    if (toDate) {
      query += ` AND d.created_at <= $${paramIndex++}`;
      params.push(toDate);
    }

    query += ` ORDER BY d.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    // Get count for pagination
    let countQuery = `
      SELECT COUNT(*)
      FROM drives
      WHERE delivery_guy_id = $1
    `;

    const countParams = [id];
    let countParamIndex = 2;

    if (status) {
      countQuery += ` AND status = $${countParamIndex++}`;
      countParams.push(status);
    }

    if (fromDate) {
      countQuery += ` AND created_at >= $${countParamIndex++}`;
      countParams.push(fromDate);
    }

    if (toDate) {
      countQuery += ` AND created_at <= $${countParamIndex++}`;
      countParams.push(toDate);
    }

    const countResult = await pool.query(countQuery, countParams);
    const totalCount = parseInt(countResult.rows[0].count);

    res.json({
      drives: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        totalCount,
        totalPages: Math.ceil(totalCount / limit),
      },
    });
  } catch (error) {
    console.error("Get delivery person drives error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDeliveryPersonPerformance = async (req, res) => {
  try {
    const { id } = req.params;
    const { fromDate, toDate } = req.query;

    // Check if delivery person exists
    const checkResult = await pool.query(
      "SELECT name FROM delivery_guys WHERE delivery_guy_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Delivery person not found" });
    }

    // Build date filter
    let dateFilter = "";
    const params = [id];
    let paramIndex = 2;

    if (fromDate) {
      dateFilter += ` AND d.created_at >= $${paramIndex++}`;
      params.push(fromDate);
    }

    if (toDate) {
      dateFilter += ` AND d.created_at <= $${paramIndex++}`;
      params.push(toDate);
    }

    // Get drive metrics
    const drivesResult = await pool.query(
      `
      SELECT
        COUNT(*) as totalDrives,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completedDrives,
        SUM(CASE WHEN status = 'ongoing' THEN 1 ELSE 0 END) as ongoingDrives,
        SUM(stock) as totalStock,
        SUM(sold) as totalSold,
        SUM(returned) as totalReturned,
        SUM(total_amount) as totalRevenue,
        AVG(EXTRACT(EPOCH FROM (end_time - start_time))/3600) as avgDriveHours
      FROM drives d
      WHERE delivery_guy_id = $1 ${dateFilter}
    `,
      params
    );

    // Get sales metrics
    const salesQuery = `
      SELECT
        COUNT(DISTINCT dcs.customer_id) as total_customersServed,
        SUM(dcs.quantity) as totalUnitsSold,
        SUM(dcs.total_amount) as totalSalesAmount,
        COUNT(DISTINCT d.drive_id) as drivesWithSales
      FROM drive_customers_sales dcs
      JOIN drives d ON dcs.drive_id = d.drive_id
      WHERE d.delivery_guy_id = $1 ${dateFilter}
    `;

    const salesResult = await pool.query(salesQuery, params);

    // Get route metrics
    const routeQuery = `
      SELECT
        r.name as route_name,
        COUNT(*) as driveCount,
        SUM(d.sold) as unitsSold,
        SUM(d.total_amount) as revenue
      FROM drives d
      JOIN routes r ON d.route_id = r.route_id
      WHERE d.delivery_guy_id = $1 ${dateFilter}
      GROUP BY r.name
      ORDER BY driveCount DESC
    `;

    const routesResult = await pool.query(routeQuery, params);

    // Calculate performance metrics
    const driveMetrics = drivesResult.rows[0];
    const salesMetrics = salesResult.rows[0];

    const deliveryEfficiency =
      driveMetrics.totalstock > 0
        ? (driveMetrics.totalsold / driveMetrics.totalstock) * 100
        : 0;

    const avgSalesPerDrive =
      driveMetrics.totaldrives > 0
        ? salesMetrics.totalsalesamount / driveMetrics.totaldrives
        : 0;

    const performance = {
      deliveryPersonName: checkResult.rows[0].name,
      overallMetrics: {
        totalDrives: parseInt(driveMetrics.totaldrives) || 0,
        completedDrives: parseInt(driveMetrics.completeddrives) || 0,
        ongoingDrives: parseInt(driveMetrics.ongoingdrives) || 0,
        completionRate:
          driveMetrics.totaldrives > 0
            ? (driveMetrics.completeddrives / driveMetrics.totaldrives) * 100
            : 0,
        avgDriveHours: parseFloat(driveMetrics.avgdrivehours) || 0,
      },
      salesMetrics: {
        totalUnitsSold: parseInt(salesMetrics.totalunitssold) || 0,
        totalRevenue: parseFloat(salesMetrics.totalsalesamount) || 0,
        total_customersServed: parseInt(salesMetrics.totalcustomersserved) || 0,
        deliveryEfficiency,
        avgSalesPerDrive,
      },
      routePerformance: routesResult.rows.map((route) => ({
        route_name: route.routename,
        driveCount: parseInt(route.drivecount),
        unitsSold: parseInt(route.unitssold) || 0,
        revenue: parseFloat(route.revenue) || 0,
      })),
    };

    res.json({ performance });
  } catch (error) {
    console.error("Get delivery person performance error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
