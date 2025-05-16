import pool from "../config/database.js";

export const getPayments = async (req, res) => {
  try {
    // Get pagination parameters from query
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // Get filter parameters
    const { customer_id, fromDate, toDate, mode, status } = req.query;

    let query = `
      SELECT pl.*, c.name as customerName, c.phone as customerPhone
      FROM payment_logs pl
      JOIN customers c ON pl.customer_id = c.customer_id
      WHERE 1=1
    `;

    const params = [];

    // Apply filters if provided
    if (customer_id) {
      params.push(customer_id);
      query += ` AND pl.customer_id = $${params.length}`;
    }

    if (fromDate) {
      params.push(fromDate);
      query += ` AND pl.date >= $${params.length}`;
    }

    if (toDate) {
      params.push(toDate);
      query += ` AND pl.date <= $${params.length}`;
    }

    if (mode) {
      params.push(mode);
      query += ` AND pl.mode = $${params.length}`;
    }

    if (status) {
      params.push(status);
      query += ` AND pl.status = $${params.length}`;
    }

    // Add pagination
    query += ` ORDER BY pl.date DESC LIMIT $${params.length + 1} OFFSET $${
      params.length + 2
    }`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    // Get total count for pagination
    let countQuery = `
      SELECT COUNT(*)
      FROM payment_logs pl
      WHERE 1=1
    `;

    const countParams = [];

    if (customer_id) {
      countParams.push(customer_id);
      countQuery += ` AND pl.customer_id = $${countParams.length}`;
    }

    if (fromDate) {
      countParams.push(fromDate);
      countQuery += ` AND pl.date >= $${countParams.length}`;
    }

    if (toDate) {
      countParams.push(toDate);
      countQuery += ` AND pl.date <= $${countParams.length}`;
    }

    if (mode) {
      countParams.push(mode);
      countQuery += ` AND pl.mode = $${countParams.length}`;
    }

    if (status) {
      countParams.push(status);
      countQuery += ` AND pl.status = $${countParams.length}`;
    }

    const countResult = await pool.query(countQuery, countParams);
    const totalCount = parseInt(countResult.rows[0].count);

    res.json({
      payments: result.rows,
      pagination: {
        page,
        limit,
        totalCount,
        totalPages: Math.ceil(totalCount / limit),
      },
    });
  } catch (error) {
    console.error("Get payments error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getPaymentById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT pl.*, c.name as customerName, c.phone as customerPhone
       FROM payment_logs pl
       JOIN customers c ON pl.customer_id = c.customer_id
       WHERE pl.payment_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Payment not found" });
    }

    res.json({ payment: result.rows[0] });
  } catch (error) {
    console.error("Get payment by ID error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const createPayment = async (req, res) => {
  try {
    const { customer_id, amount, mode, remarks, date } = req.body;

    // Basic validation
    if (!customer_id || !amount || !mode) {
      return res
        .status(400)
        .json({ message: "Customer ID, amount, and mode are required" });
    }

    // Check if amount is valid
    if (amount <= 0) {
      return res.status(400).json({ message: "Amount must be greater than 0" });
    }

    // Check if customer exists
    const customerCheck = await pool.query(
      "SELECT customer_id FROM customers WHERE customer_id = $1",
      [customer_id]
    );

    if (customerCheck.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    // Create payment with transaction to update customer points
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // Create payment log
      const paymentResult = await client.query(
        `INSERT INTO payment_logs (customer_id, amount, mode, remarks, date)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`,
        [customer_id, amount, mode, remarks || null, date || new Date()]
      );

      // Add points to customer (1 point for each unit of currency)
      const points = Math.floor(amount);
      if (points > 0) {
        await client.query(
          `UPDATE customers
           SET points = points + $1, updated_at = NOW()
           WHERE customer_id = $2`,
          [points, customer_id]
        );
      }

      await client.query("COMMIT");

      // Get updated customer data
      const customerResult = await pool.query(
        "SELECT points FROM customers WHERE customer_id = $1",
        [customer_id]
      );

      res.status(201).json({
        message: "Payment recorded successfully",
        payment: paymentResult.rows[0],
        customerPoints: customerResult.rows[0].points,
      });
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Create payment error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const updatePayment = async (req, res) => {
  try {
    const { id } = req.params;
    const { amount, mode, status, remarks } = req.body;

    // Check if payment exists
    const paymentCheck = await pool.query(
      "SELECT * FROM payment_logs WHERE payment_id = $1",
      [id]
    );

    if (paymentCheck.rows.length === 0) {
      return res.status(404).json({ message: "Payment not found" });
    }

    const originalPayment = paymentCheck.rows[0];

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramCounter = 1;

    if (amount !== undefined) {
      if (amount <= 0) {
        return res
          .status(400)
          .json({ message: "Amount must be greater than 0" });
      }
      updates.push(`amount = $${paramCounter++}`);
      values.push(amount);
    }

    if (mode) {
      updates.push(`mode = $${paramCounter++}`);
      values.push(mode);
    }

    if (status) {
      updates.push(`status = $${paramCounter++}`);
      values.push(status);
    }

    if (remarks !== undefined) {
      updates.push(`remarks = $${paramCounter++}`);
      values.push(remarks);
    }

    updates.push(`updated_at = $${paramCounter++}`);
    values.push(new Date());

    if (updates.length === 1) {
      // Only updated_at was added
      return res
        .status(400)
        .json({ message: "No valid fields provided for update" });
    }

    // Add payment ID to values array
    values.push(id);

    // Handle transaction to update customer points if amount changes
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // Update payment
      const result = await client.query(
        `UPDATE payment_logs
         SET ${updates.join(", ")}
         WHERE payment_id = $${paramCounter}
         RETURNING *`,
        values
      );

      // Update customer points if amount changed
      if (amount !== undefined && amount !== originalPayment.amount) {
        const pointsDifference =
          Math.floor(amount) - Math.floor(originalPayment.amount);

        if (pointsDifference !== 0) {
          await client.query(
            `UPDATE customers
             SET points = points + $1, updated_at = NOW()
             WHERE customer_id = $2`,
            [pointsDifference, originalPayment.customer_id]
          );
        }
      }

      await client.query("COMMIT");

      res.json({
        message: "Payment updated successfully",
        payment: result.rows[0],
      });
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Update payment error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const deletePayment = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if payment exists
    const paymentCheck = await pool.query(
      "SELECT * FROM payment_logs WHERE payment_id = $1",
      [id]
    );

    if (paymentCheck.rows.length === 0) {
      return res.status(404).json({ message: "Payment not found" });
    }

    const payment = paymentCheck.rows[0];

    // Delete payment and adjust customer points in a transaction
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // Delete payment
      await client.query("DELETE FROM payment_logs WHERE payment_id = $1", [id]);

      // Deduct points from customer
      const pointsToDeduct = Math.floor(payment.amount);
      if (pointsToDeduct > 0) {
        await client.query(
          `UPDATE customers
           SET points = GREATEST(0, points - $1), updated_at = NOW()
           WHERE customer_id = $2`,
          [pointsToDeduct, payment.customer_id]
        );
      }

      await client.query("COMMIT");

      res.json({
        message: "Payment deleted successfully",
        deductedPoints: pointsToDeduct,
      });
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Delete payment error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getOverdueAccounts = async (req, res) => {
  try {
    // This is a placeholder implementation since overdue logic would depend on business rules
    // Assuming overdue means no payments in the last 30 days for active customers

    const result = await pool.query(
      `SELECT c.customer_id, c.name, c.phone, c.location, c.address,
              COALESCE(MAX(pl.date), NULL) as lastPaymentDate,
              CURRENT_DATE - COALESCE(MAX(pl.date), c.created_at::date) as daysSinceLastPayment
       FROM customers c
       LEFT JOIN payment_logs pl ON c.customer_id = pl.customer_id
       WHERE c.status = 'active'
       GROUP BY c.customer_id, c.name, c.phone, c.location, c.address, c.created_at
       HAVING CURRENT_DATE - COALESCE(MAX(pl.date), c.created_at::date) > 30
       ORDER BY daysSinceLastPayment DESC`
    );

    res.json({
      overdueAccounts: result.rows,
      count: result.rows.length,
    });
  } catch (error) {
    console.error("Get overdue accounts error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const generateReceipt = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if payment exists
    const result = await pool.query(
      `SELECT pl.*, c.name as customerName, c.phone as customerPhone
       FROM payment_logs pl
       JOIN customers c ON pl.customer_id = c.customer_id
       WHERE pl.payment_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Payment not found" });
    }

    const payment = result.rows[0];

    // In a real implementation, you would generate a PDF receipt here
    // This is a placeholder returning receipt data

    const receipt = {
      receiptNumber: `REC-${payment.paymentid.toString().padStart(6, "0")}`,
      date: payment.date,
      customerName: payment.customername,
      customerPhone: payment.customerphone,
      amount: payment.amount,
      paymentMode: payment.mode,
      status: payment.status,
      remarks: payment.remarks,
    };

    res.json({
      receipt,
      pdfUrl: `/receipts/${receipt.receiptNumber}.pdf`, // This would be a real URL in production
    });
  } catch (error) {
    console.error("Generate receipt error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const sendReceipt = async (req, res) => {
  try {
    const { id } = req.params;
    const { method } = req.body; // 'sms' or 'email'

    if (!method || !["sms", "email"].includes(method)) {
      return res
        .status(400)
        .json({ message: "Valid method (sms or email) is required" });
    }

    // Check if payment exists
    const result = await pool.query(
      `SELECT pl.*, c.name as customerName, c.phone as customerPhone
       FROM payment_logs pl
       JOIN customers c ON pl.customer_id = c.customer_id
       WHERE pl.payment_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Payment not found" });
    }

    const payment = result.rows[0];

    // In a real implementation, you would:
    // 1. Generate receipt
    // 2. Send via SMS or email using a service

    res.json({
      message: `Receipt sent via ${method} successfully`,
      sentTo: method === "sms" ? payment.customerphone : "email@example.com",
      payment_id: payment.paymentid,
    });
  } catch (error) {
    console.error("Send receipt error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
