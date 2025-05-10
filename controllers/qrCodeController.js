import pool from "../config/database.js";
import crypto from "crypto";
import QRCode from "qrcode";
import { v4 as uuidv4 } from "uuid";

export const getQrCodes = async (req, res) => {
  try {
    const { page = 1, limit = 10, status, customer_id } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT q.*, c.name as customerName, c.phone as customerPhone
      FROM qr_codes q
      LEFT JOIN customers c ON q.customer_id = c.customer_id
      WHERE 1=1
    `;

    const params = [];

    if (status) {
      params.push(status);
      query += ` AND q.status = $${params.length}`;
    }

    if (customer_id) {
      params.push(customer_id);
      query += ` AND q.customer_id = $${params.length}`;
    }

    // Add order by and pagination
    query += ` ORDER BY q.created_at DESC LIMIT $${params.length + 1} OFFSET $${
      params.length + 2
    }`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    // Get total count for pagination
    let countQuery = `
      SELECT COUNT(*)
      FROM qr_codes q
      WHERE 1=1
    `;

    const countParams = [];

    if (status) {
      countParams.push(status);
      countQuery += ` AND q.status = $${countParams.length}`;
    }

    if (customer_id) {
      countParams.push(customer_id);
      countQuery += ` AND q.customer_id = $${countParams.length}`;
    }

    const countResult = await pool.query(countQuery, countParams);
    const totalCount = parseInt(countResult.rows[0].count);

    res.json({
      qrCodes: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        totalCount,
        totalPages: Math.ceil(totalCount / limit),
      },
    });
  } catch (error) {
    console.error("Get QR codes error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getQrCodeById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT q.*, c.name as customerName, c.phone as customerPhone
       FROM qr_codes q
       LEFT JOIN customers c ON q.customer_id = c.customer_id
       WHERE q.qr_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "QR code not found" });
    }

    res.json({
      qrCode: result.rows[0],
    });
  } catch (error) {
    console.error("Get QR code error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const generateQrCodes = async (req, res) => {
  try {
    const { count = 1 } = req.body;

    if (count < 1 || count > 100) {
      return res
        .status(400)
        .json({ message: "Count must be between 1 and 100" });
    }

    const generatedQrCodes = [];

    for (let i = 0; i < count; i++) {
      // Generate a unique code
      const code = uuidv4();

      // Insert into database
      const result = await pool.query(
        "INSERT INTO qr_codes (code, status) VALUES ($1, 'inactive') RETURNING *",
        [code]
      );

      generatedQrCodes.push(result.rows[0]);
    }

    res.status(201).json({
      message: `${count} QR code(s) generated successfully`,
      qrCodes: generatedQrCodes,
    });
  } catch (error) {
    console.error("Generate QR codes error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const assignQrToCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    const { customer_id } = req.body;

    if (!customer_id) {
      return res.status(400).json({ message: "Customer ID is required" });
    }

    // Check if QR code exists
    const qrCheckResult = await pool.query(
      "SELECT * FROM qr_codes WHERE qr_id = $1",
      [id]
    );

    if (qrCheckResult.rows.length === 0) {
      return res.status(404).json({ message: "QR code not found" });
    }

    const qrCode = qrCheckResult.rows[0];

    // Check if QR code is already assigned to another customer
    if (qrCode.customer_id && qrCode.customer_id !== customer_id) {
      return res
        .status(400)
        .json({ message: "QR code is already assigned to another customer" });
    }

    // Check if customer exists
    const customerCheckResult = await pool.query(
      "SELECT customer_id FROM customers WHERE customer_id = $1",
      [customer_id]
    );

    if (customerCheckResult.rows.length === 0) {
      return res.status(404).json({ message: "Customer not found" });
    }

    // Assign QR code to customer
    const result = await pool.query(
      `UPDATE qr_codes
       SET customer_id = $1, status = 'active', activated_at = NOW(), updated_at = NOW()
       WHERE qr_id = $2
       RETURNING *`,
      [customer_id, id]
    );

    res.json({
      message: "QR code assigned to customer successfully",
      qrCode: result.rows[0],
    });
  } catch (error) {
    console.error("Assign QR code error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const updateQrCodeStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status || !["active", "inactive", "expired"].includes(status)) {
      return res.status(400).json({
        message: "Valid status (active, inactive, expired) is required",
      });
    }

    // Check if QR code exists
    const qrCheckResult = await pool.query(
      "SELECT qr_id FROM qr_codes WHERE qr_id = $1",
      [id]
    );

    if (qrCheckResult.rows.length === 0) {
      return res.status(404).json({ message: "QR code not found" });
    }

    // Update QR code status
    const result = await pool.query(
      `UPDATE qr_codes
       SET status = $1, updated_at = NOW(),
       activated_at = CASE WHEN $1 = 'active' AND activated_at IS NULL THEN NOW() ELSE activated_at END
       WHERE qr_id = $2
       RETURNING *`,
      [status, id]
    );

    res.json({
      message: "QR code status updated successfully",
      qrCode: result.rows[0],
    });
  } catch (error) {
    console.error("Update QR code status error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const downloadQrCodes = async (req, res) => {
  try {
    const { ids } = req.query;

    let query = "SELECT * FROM qr_codes WHERE 1=1";
    const params = [];

    if (ids) {
      const idArray = ids
        .split(",")
        .map((id) => parseInt(id))
        .filter((id) => !isNaN(id));
      if (idArray.length > 0) {
        params.push(idArray);
        query += ` AND qr_id = ANY($${params.length})`;
      }
    }

    const result = await pool.query(query, params);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "No QR codes found" });
    }

    // Generate QR code images
    const qrCodesWithImages = await Promise.all(
      result.rows.map(async (qr) => {
        try {
          // In a real app, this would generate an image file
          // For now, we'll just generate a data URL
          const dataUrl = await QRCode.toDataURL(qr.code);
          return {
            ...qr,
            imageDataUrl: dataUrl,
          };
        } catch (err) {
          console.error("Error generating QR image:", err);
          return {
            ...qr,
            imageDataUrl: null,
            error: "Failed to generate QR image",
          };
        }
      })
    );

    // In a real application, you would:
    // 1. Generate a PDF with all QR codes
    // 2. Save it temporarily
    // 3. Send it as a download
    // For this example, we'll just return the data URLs

    res.json({
      message: `${qrCodesWithImages.length} QR code(s) ready for download`,
      qrCodes: qrCodesWithImages,
    });
  } catch (error) {
    console.error("Download QR codes error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const replaceQrCode = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if QR code exists
    const qrCheckResult = await pool.query(
      "SELECT * FROM qr_codes WHERE qr_id = $1",
      [id]
    );

    if (qrCheckResult.rows.length === 0) {
      return res.status(404).json({ message: "QR code not found" });
    }

    const oldQrCode = qrCheckResult.rows[0];

    // Generate a new QR code with same customer
    const newCode = uuidv4();

    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // Deactivate old QR code
      await client.query(
        "UPDATE qr_codes SET status = 'expired', updated_at = NOW() WHERE qr_id = $1",
        [id]
      );

      // Create new QR code
      const newQrResult = await client.query(
        `INSERT INTO qr_codes (code, customer_id, status, activated_at)
         VALUES ($1, $2, 'active', NOW())
         RETURNING *`,
        [newCode, oldQrCode.customer_id]
      );

      await client.query("COMMIT");

      res.json({
        message: "QR code replaced successfully",
        oldQrCode,
        newQrCode: newQrResult.rows[0],
      });
    } catch (err) {
      await client.query("ROLLBACK");
      throw err;
    } finally {
      client.release();
    }
  } catch (error) {
    console.error("Replace QR code error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
