import pool from "../config/database.js";
import { isValidDateTime } from "../utils/dateValidation.js";

export const getCustomers = async (req, res) => {
  try {
    // Get pagination parameters from query
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 500;
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

/* export const getCustomerById = async (req, res) => {
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
      "SELECT *, ABS(points) as points FROM point_transactions WHERE customer_id = $1 ORDER BY created_at DESC",
      [id]
    );
    customer.transactions = transactionResult.rows;

    // Add merge payment logs in transactions

    res.json({ customer: customer });
  } catch (error) {
    console.error("Get customer by ID error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
 */

export const getCustomerById = async (req, res) => {
  try {
    const { id } = req.params;

    // Get date range parameters from query
    const {
      fromDate,
      toDate,
      transactionType,
      limit = 500,
      page = 1
    } = req.query;

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

    // Build dynamic transaction query with filters
    let transactionQuery = `
      SELECT * FROM point_transactions
      WHERE customer_id = $1
    `;
    const transactionParams = [id];
    let paramCounter = 2;

    // Add date range filters
    if (fromDate) {
      transactionQuery += ` AND DATE(created_at) >= $${paramCounter}`;
      transactionParams.push(fromDate);
      paramCounter++;
    }

    if (toDate) {
      transactionQuery += ` AND DATE(created_at) <= $${paramCounter}`;
      transactionParams.push(toDate);
      paramCounter++;
    }

    // Add transaction type filter
    if (transactionType && ["credit", "debit"].includes(transactionType)) {
      transactionQuery += ` AND transaction_type = $${paramCounter}`;
      transactionParams.push(transactionType);
      paramCounter++;
    }

    // Add ordering and pagination
    transactionQuery += ` ORDER BY date DESC`;

    if (limit) {
      const offset = (parseInt(page) - 1) * parseInt(limit);
      transactionQuery += ` LIMIT $${paramCounter} OFFSET $${paramCounter + 1}`;
      transactionParams.push(parseInt(limit), offset);
    }

    // Execute transaction query
    const transactionResult = await pool.query(
      transactionQuery,
      transactionParams
    );

    // Get total count for pagination (with same filters)
    let countQuery = `
      SELECT COUNT(*) FROM point_transactions
      WHERE customer_id = $1
    `;
    const countParams = [id];
    let countParamCounter = 2;

    if (fromDate) {
      countQuery += ` AND DATE(created_at) >= $${countParamCounter}`;
      countParams.push(fromDate);
      countParamCounter++;
    }

    if (toDate) {
      countQuery += ` AND DATE(created_at) <= $${countParamCounter}`;
      countParams.push(toDate);
      countParamCounter++;
    }

    if (transactionType && ["credit", "debit"].includes(transactionType)) {
      countQuery += ` AND transaction_type = $${countParamCounter}`;
      countParams.push(transactionType);
    }

    const countResult = await pool.query(countQuery, countParams);
    const totalTransactions = parseInt(countResult.rows[0].count);

    // Calculate transaction summary for the filtered period
    let summaryQuery = `
      SELECT
        COUNT(*) as total_transactions,
        SUM(CASE WHEN transaction_type = 'credit' THEN points ELSE 0 END) as total_credits,
        SUM(CASE WHEN transaction_type = 'debit' THEN points ELSE 0 END) as total_debits,
        SUM(CASE WHEN transaction_type = 'credit' THEN points ELSE -points END) as net_change
      FROM point_transactions
      WHERE customer_id = $1
    `;
    const summaryParams = [id];
    let summaryParamCounter = 2;

    if (fromDate) {
      summaryQuery += ` AND DATE(created_at) >= $${summaryParamCounter}`;
      summaryParams.push(fromDate);
      summaryParamCounter++;
    }

    if (toDate) {
      summaryQuery += ` AND DATE(created_at) <= $${summaryParamCounter}`;
      summaryParams.push(toDate);
      summaryParamCounter++;
    }

    if (transactionType && ["credit", "debit"].includes(transactionType)) {
      summaryQuery += ` AND transaction_type = $${summaryParamCounter}`;
      summaryParams.push(transactionType);
    }

    const summaryResult = await pool.query(summaryQuery, summaryParams);
    const transactionSummary = summaryResult.rows[0];

    // Attach transactions with pagination info
    customer.transactions = {
      data: transactionResult.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        totalCount: totalTransactions,
        totalPages: Math.ceil(totalTransactions / parseInt(limit))
      },
      filters: {
        fromDate: fromDate || null,
        toDate: toDate || null,
        transactionType: transactionType || null
      },
      summary: {
        totalTransactions: parseInt(transactionSummary.total_transactions),
        totalCredits: parseFloat(transactionSummary.total_credits) || 0,
        totalDebits: parseFloat(transactionSummary.total_debits) || 0,
        netChange: parseFloat(transactionSummary.net_change) || 0
      }
    };

    // Add validation for fromDate and toDate
    if (fromDate && !isValidDateTime(fromDate)) {
      return res.status(400).json({
        message:
          "Invalid fromDate format. Please use YYYY-MM-DD or YYYY-MM-DD HH:MM:SS",
        receivedDate: fromDate
      });
    }

    if (toDate && !isValidDateTime(toDate)) {
      return res.status(400).json({
        message:
          "Invalid toDate format. Please use YYYY-MM-DD or YYYY-MM-DD HH:MM:SS",
        receivedDate: toDate
      });
    }

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

// export const deleteCustomer = async (req, res) => {
//   try {
//     const { id } = req.params;

//     // Check if customer exists
//     const checkResult = await pool.query(
//       "SELECT customer_id FROM customers WHERE customer_id = $1",
//       [id]
//     );

//     if (checkResult.rows.length === 0) {
//       return res.status(404).json({ message: "Customer not found" });
//     }

//     // Delete customer
//     await pool.query("DELETE FROM customers WHERE customer_id = $1", [id]);

//     res.json({ message: "Customer deleted successfully" });
//   } catch (error) {
//     console.error("Delete customer error:", error);
//     res.status(500).json({ message: "Server error" });
//   }
// };

export const deleteCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    const { force = true } = req.query; // Use ?force=true to enable cascade deletion

    // Check if customer exists
    const checkResult = await pool.query(
      "SELECT customer_id, name, photo FROM customers WHERE customer_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    const customer = checkResult.rows[0];

    // Check all foreign key relationships
    const [
      qrCodesCheck,
      routesCheck,
      salesCheck,
      paymentsCheck,
      transactionsCheck
    ] = await Promise.all([
      pool.query(
        "SELECT COUNT(*) as count FROM qr_codes WHERE customer_id = $1",
        [id]
      ),
      pool.query(
        "SELECT COUNT(*) as count FROM route_customers WHERE customer_id = $1",
        [id]
      ),
      pool.query(
        "SELECT COUNT(*) as count FROM drive_customers_sales WHERE customer_id = $1",
        [id]
      ),
      pool.query(
        "SELECT COUNT(*) as count FROM payment_logs WHERE customer_id = $1",
        [id]
      ),
      pool.query(
        "SELECT COUNT(*) as count FROM point_transactions WHERE customer_id = $1",
        [id]
      )
    ]);

    const associatedRecords = {
      qrCodes: parseInt(qrCodesCheck.rows[0].count),
      routes: parseInt(routesCheck.rows[0].count),
      sales: parseInt(salesCheck.rows[0].count),
      payments: parseInt(paymentsCheck.rows[0].count),
      transactions: parseInt(transactionsCheck.rows[0].count)
    };

    const totalAssociatedRecords = Object.values(associatedRecords).reduce(
      (sum, count) => sum + count,
      0
    );

    // If no associated records, proceed with simple deletion
    if (totalAssociatedRecords === 0) {
      // Delete photo file if exists
      if (customer.photo) {
        try {
          const fs = await import("fs");
          fs.unlinkSync(customer.photo);
        } catch (error) {
          console.log("Photo file not found or already deleted");
        }
      }

      await pool.query("DELETE FROM customers WHERE customer_id = $1", [id]);

      return res.json({
        message: "Customer deleted successfully",
        deletedCustomer: {
          customer_id: customer.customer_id,
          name: customer.name
        }
      });
    }

    // If has associated records but force is false, show warning
    if (!force) {
      return res.status(400).json({
        message:
          "Customer has associated records. Use ?force=true to delete all associated data.",
        customer: {
          customer_id: customer.customer_id,
          name: customer.name
        },
        associatedRecords: associatedRecords,
        totalAssociatedRecords: totalAssociatedRecords,
        warning:
          "Using force=true will permanently delete all associated data including QR codes, routes, sales history, payments, and point transactions!",
        deletionUrl: `${req.originalUrl}?force=true`
      });
    }

    // Force deletion with cascade - use transaction for data integrity
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      console.log(
        `Starting cascade deletion for customer ${id} (${customer.name})`
      );

      // Delete in correct order (children first, then parent)
      // 1. Delete point transactions
      if (associatedRecords.transactions > 0) {
        await client.query(
          "DELETE FROM point_transactions WHERE customer_id = $1",
          [id]
        );
        console.log(
          `Deleted ${associatedRecords.transactions} point transactions`
        );
      }

      // 2. Delete QR codes
      if (associatedRecords.qrCodes > 0) {
        await client.query("DELETE FROM qr_codes WHERE customer_id = $1", [id]);
        console.log(`Deleted ${associatedRecords.qrCodes} QR codes`);
      }

      // 3. Delete route associations
      if (associatedRecords.routes > 0) {
        await client.query(
          "DELETE FROM route_customers WHERE customer_id = $1",
          [id]
        );
        console.log(`Deleted ${associatedRecords.routes} route associations`);
      }

      // 4. Delete sales records
      if (associatedRecords.sales > 0) {
        await client.query(
          "DELETE FROM drive_customers_sales WHERE customer_id = $1",
          [id]
        );
        console.log(`Deleted ${associatedRecords.sales} sales records`);
      }

      // 5. Delete payment logs
      if (associatedRecords.payments > 0) {
        await client.query("DELETE FROM payment_logs WHERE customer_id = $1", [
          id
        ]);
        console.log(`Deleted ${associatedRecords.payments} payment logs`);
      }

      // 6. Finally delete the customer
      await client.query("DELETE FROM customers WHERE customer_id = $1", [id]);
      console.log(`Deleted customer ${customer.name}`);

      await client.query("COMMIT");

      // Delete photo file after successful database deletion
      if (customer.photo) {
        try {
          const fs = await import("fs");
          fs.unlinkSync(customer.photo);
          console.log(`Deleted photo file: ${customer.photo}`);
        } catch (error) {
          console.log("Photo file not found or already deleted");
        }
      }

      res.json({
        message: "Customer and all associated records deleted successfully",
        deletedCustomer: {
          customer_id: customer.customer_id,
          name: customer.name
        },
        deletedRecords: {
          ...associatedRecords,
          photoFile: customer.photo ? true : false
        },
        totalRecordsDeleted: totalAssociatedRecords + 1 // +1 for the customer record
      });
    } catch (error) {
      await client.query("ROLLBACK");
      console.error("Cascade deletion failed:", error);
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Delete customer error:", error);

    // Enhanced error handling for foreign key constraints
    if (error.code === "23503") {
      const detail = error.detail || "";
      const table = error.table || "unknown";

      return res.status(400).json({
        message: `Cannot delete customer due to foreign key constraint in table '${table}'. Use ?force=true to cascade delete all associated records.`,
        error: "Foreign key constraint violation",
        detail: detail,
        solution:
          "Add ?force=true to your request URL to enable cascade deletion"
      });
    }

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
    var { points } = req.body;

    const transactionType = points < 0 ? "debit" : "credit";

    if (!points) {
      return res
        .status(400)
        .json({ message: "Valid points value is required" });
    }

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
        [
          id,
          transactionType,
          Math.abs(points),
          currentPoints,
          newBalance,
          req.user.user_id
        ]
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
    const { points, date } = req.body;

    if (!points || points <= 0) {
      return res
        .status(400)
        .json({ message: "Valid points value is required" });
    }

    // check date format
    if (date && !isValidDateTime(date)) {
      return res.status(400).json({
        message:
          "Invalid date format. Please use YYYY-MM-DD or YYYY-MM-DD HH:MM:SS",
        receivedDate: date
      });
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
    const stopLoss = parseInt(checkResult.rows[0].stop_loss) * -1;

    // Check if customer has stop_loss and if current points would go below stop_loss after deduction

    // if ( !stopLoss && stopLoss < (currentPoints - points) ) {
    if (
      currentPoints <= 0 &&
      currentPoints - points <= 0 &&
      stopLoss &&
      currentPoints - points < stopLoss
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
         (customer_id, transaction_type, points, previous_balance, new_balance, date, performed_by)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          id,
          "debit",
          points,
          currentPoints,
          newBalance,
          // reason || "Manual deduction",
          date || null,
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
    const limit = parseInt(req.query.limit) || 500;
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
    const limit = parseInt(req.query.limit) || 500;
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
    const limit = parseInt(req.query.limit) || 500;
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

// Helper function to recalculate customer balance from all transactions
const recalculateCustomerBalance = async (customerId, client = pool) => {
  const result = await client.query(
    `
    SELECT COALESCE(SUM(CASE
      WHEN transaction_type = 'credit' THEN points
      ELSE -points
    END), 0) as total_balance
    FROM point_transactions
    WHERE customer_id = $1
  `,
    [customerId]
  );

  return parseInt(result.rows[0].total_balance);
};

// Helper function to recalculate transaction balances chronologically
const recalculateTransactionBalances = async (customerId, client = pool) => {
  // Get all transactions for this customer in chronological order
  const transactionsResult = await client.query(
    `
    SELECT transaction_id, transaction_type, points
    FROM point_transactions
    WHERE customer_id = $1
    ORDER BY created_at ASC, transaction_id ASC
  `,
    [customerId]
  );

  const transactions = transactionsResult.rows;
  let runningBalance = 0;

  // Calculate and update balances for each transaction
  for (let i = 0; i < transactions.length; i++) {
    const transaction = transactions[i];
    const previousBalance = runningBalance;

    // Calculate new balance based on transaction type
    if (transaction.transaction_type === "credit") {
      runningBalance += parseInt(transaction.points);
    } else {
      runningBalance -= parseInt(transaction.points);
    }

    // Update the transaction with correct balances
    await client.query(
      `
      UPDATE point_transactions
      SET previous_balance = $1, new_balance = $2
      WHERE transaction_id = $3
    `,
      [previousBalance, runningBalance, transaction.transaction_id]
    );
  }

  return runningBalance; // Final customer balance
};

// Edit transaction method
export const updateTransaction = async (req, res) => {
  try {
    const { customerId, transactionId } = req.params;
    const { points, reason, date } = req.body;

    // 1. Admin role check
    if (req.user.role !== "admin") {
      return res
        .status(403)
        .json({ message: "Only admin can edit transactions" });
    }

    // 2. Basic validation
    if (!points || points <= 0) {
      return res
        .status(400)
        .json({ message: "Valid points value is required" });
    }

    if (date && !isValidDateTime(date)) {
      return res.status(400).json({
        message:
          "Invalid date format. Please use YYYY-MM-DD or YYYY-MM-DD HH:MM:SS",
        receivedDate: date
      });
    }

    // 3. Get the existing transaction
    const existingTransactionResult = await pool.query(
      "SELECT * FROM point_transactions WHERE transaction_id = $1 AND customer_id = $2",
      [transactionId, customerId]
    );

    if (existingTransactionResult.rows.length === 0) {
      return res.status(404).json({ message: "Transaction not found" });
    }

    const existingTransaction = existingTransactionResult.rows[0];

    // 4. Only allow editing debit transactions
    if (existingTransaction.transaction_type !== "debit") {
      return res.status(400).json({
        message: "Only debit transactions can be edited"
      });
    }

    // 5. Don't allow editing payment-related transactions
    if (
      existingTransaction.reason &&
      existingTransaction.reason.includes("Payment ID")
    ) {
      return res.status(400).json({
        message: "Payment-related transactions cannot be edited"
      });
    }

    // 6. Check if this transaction is within last 10 debit transactions for this customer
    const recentTransactionsResult = await pool.query(
      `SELECT transaction_id
       FROM point_transactions
       WHERE customer_id = $1
         AND transaction_type = 'debit'
         AND (reason IS NULL OR reason NOT LIKE '%Payment ID%')
       ORDER BY created_at DESC
       LIMIT 10`,
      [customerId]
    );

    const recentTransactionIds = recentTransactionsResult.rows.map(
      (row) => row.transaction_id
    );

    if (!recentTransactionIds.includes(parseInt(transactionId))) {
      return res.status(400).json({
        message: "Only last 10 debit transactions can be edited"
      });
    }

    // 7. Get customer details
    const customerResult = await pool.query(
      "SELECT points, stop_loss, name FROM customers WHERE customer_id = $1",
      [customerId]
    );

    if (customerResult.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    const customer = customerResult.rows[0];

    // Start transaction
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // 8. Store old values for audit
      const oldPoints = existingTransaction.points;
      const oldReason = existingTransaction.reason;
      const oldDate = existingTransaction.date;

      // 9. Update the transaction record (only the editable fields)
      await client.query(
        `UPDATE point_transactions
         SET points = $1,
             reason = $2,
             date = $3
         WHERE transaction_id = $4`,
        [parseInt(points), reason || oldReason, date || oldDate, transactionId]
      );

      // 10. Recalculate ALL transaction balances for this customer chronologically
      const finalCustomerBalance = await recalculateTransactionBalances(
        customerId,
        client
      );

      // 11. Check stop loss validation after recalculation
      const stopLoss = parseInt(customer.stop_loss) * -1;
      if (
        finalCustomerBalance <= 0 &&
        stopLoss &&
        finalCustomerBalance < stopLoss
      ) {
        await client.query("ROLLBACK");
        return res.status(400).json({
          message: `Cannot update transaction. New balance ${finalCustomerBalance} would be below stop loss limit of ${stopLoss}`,
          currentBalance: customer.points,
          newBalance: finalCustomerBalance,
          stopLossLimit: stopLoss
        });
      }

      // 12. Update customer's points with recalculated balance
      await client.query(
        "UPDATE customers SET points = $1, updated_at = NOW() WHERE customer_id = $2",
        [finalCustomerBalance, customerId]
      );

      // 13. Get the updated transaction for response
      const updatedTransactionResult = await client.query(
        "SELECT * FROM point_transactions WHERE transaction_id = $1",
        [transactionId]
      );

      // 14. Log the edit in audit table
      await client.query(
        `INSERT INTO transaction_audit_log
         (transaction_id, customer_id, old_points, new_points, old_reason, new_reason, old_date, new_date, edited_by, edit_timestamp)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW())`,
        [
          transactionId,
          customerId,
          oldPoints,
          parseInt(points),
          oldReason,
          reason || oldReason,
          oldDate,
          date || oldDate,
          req.user.user_id
        ]
      );

      await client.query("COMMIT");

      res.json({
        message:
          "Transaction updated successfully. All subsequent transaction balances have been recalculated.",
        transaction: updatedTransactionResult.rows[0],
        changes: {
          oldPoints: oldPoints,
          newPoints: parseInt(points),
          pointsDifference: parseInt(points) - oldPoints,
          oldReason: oldReason,
          newReason: reason || oldReason,
          oldDate: oldDate,
          newDate: date || oldDate
        },
        customerBalance: {
          previousBalance: customer.points,
          newBalance: finalCustomerBalance,
          balanceChange: finalCustomerBalance - customer.points
        },
        note: "All transaction balances for this customer have been recalculated to maintain data integrity"
      });
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Update transaction error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// Get transaction by ID with edit history
export const getTransactionById = async (req, res) => {
  try {
    const { transactionId } = req.params;

    // Get transaction details
    const transactionResult = await pool.query(
      `SELECT pt.*, c.name as customer_name, c.phone as customer_phone
       FROM point_transactions pt
       JOIN customers c ON pt.customer_id = c.customer_id
       WHERE pt.transaction_id = $1`,
      [transactionId]
    );

    if (transactionResult.rows.length === 0) {
      return res.status(404).json({ message: "Transaction not found" });
    }

    const transaction = transactionResult.rows[0];

    // Get edit history from audit table
    const auditResult = await pool.query(
      `SELECT tal.*
   FROM transaction_audit_log tal
   WHERE tal.transaction_id = $1
   ORDER BY tal.edit_timestamp DESC`,
      [transactionId]
    );
    transaction.editHistory = auditResult.rows;

    // Check if transaction is editable (last 10 debit transactions)
    const recentTransactionsResult = await pool.query(
      `
      SELECT transaction_id
      FROM point_transactions
      WHERE customer_id = $1
        AND transaction_type = 'debit'
        AND (reason IS NULL OR reason NOT LIKE '%Payment ID%')
      ORDER BY created_at DESC
      LIMIT 10
    `,
      [transaction.customer_id]
    );

    const recentTransactionIds = recentTransactionsResult.rows.map(
      (row) => row.transaction_id
    );
    transaction.isEditable =
      recentTransactionIds.includes(transaction.transaction_id) &&
      transaction.transaction_type === "debit" &&
      (!transaction.reason || !transaction.reason.includes("Payment ID"));

    res.json({ transaction });
  } catch (error) {
    console.error("Get transaction by ID error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
