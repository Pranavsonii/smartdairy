import pool from "../config/database.js";
import bcrypt from "bcrypt";

export const getUsers = async (req, res) => {
  try {
    const { role } = req.query;

    let query = `
      SELECT u.user_id, u.phone, u.role, u.created_at, u.updated_at,
             CASE
               WHEN u.delivery_guy_id IS NOT NULL THEN dg.name
               ELSE NULL
             END as delivery_guy_name
      FROM users u
      LEFT JOIN delivery_guys dg ON u.delivery_guy_id = dg.delivery_guy_id
      WHERE 1=1
    `;

    const params = [];

    if (role) {
      params.push(role);
      query += ` AND u.role = $${params.length}`;
    }

    query += ` ORDER BY u.created_at DESC`;

    const result = await pool.query(query, params);

    res.json({
      users: result.rows,
    });
  } catch (error) {
    console.error("Get users error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT u.user_id, u.phone, u.role, u.created_at, u.updated_at,
              u.delivery_guy_id,
              CASE
                WHEN u.delivery_guy_id IS NOT NULL THEN dg.name
                ELSE NULL
              END as delivery_guy_name
       FROM users u
       LEFT JOIN delivery_guys dg ON u.delivery_guy_id = dg.delivery_guy_id
       WHERE u.user_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({ user: result.rows[0] });
  } catch (error) {
    console.error("Get user by ID error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const createUser = async (req, res) => {
  try {
    const { phone, password, role, delivery_guy_id } = req.body;

    // Basic validation
    if (!phone || !password || !role) {
      return res
        .status(400)
        .json({ message: "Phone, password and role are required" });
    }

    // Check if phone already exists
    const phoneCheck = await pool.query(
      "SELECT user_id FROM users WHERE phone = $1",
      [phone]
    );

    if (phoneCheck.rows.length > 0) {
      return res.status(400).json({ message: "Phone number already in use" });
    }

    // Validate role
    if (!["admin", "driver"].includes(role)) {
      return res
        .status(400)
        .json({ message: "Invalid role. Must be 'admin' or 'driver'" });
    }

    // Validate delivery guy if role is driver
    if (role === "driver" && !delivery_guy_id) {
      return res
        .status(400)
        .json({ message: "Delivery person ID is required for driver role" });
    }

    if (delivery_guy_id) {
      const deliveryGuyCheck = await pool.query(
        "SELECT delivery_guy_id FROM delivery_guys WHERE delivery_guy_id = $1",
        [delivery_guy_id]
      );

      if (deliveryGuyCheck.rows.length === 0) {
        return res.status(404).json({ message: "Delivery person not found" });
      }

      // Check if delivery guy already has a user account
      const existingUserCheck = await pool.query(
        "SELECT user_id FROM users WHERE delivery_guy_id = $1",
        [delivery_guy_id]
      );

      if (existingUserCheck.rows.length > 0) {
        return res.status(400).json({
          message: "This delivery person already has a user account",
        });
      }
    }

    // In a production app, you would hash the password
    // const hashedPassword = await bcrypt.hash(password, 10);
    // For simplicity in this example, we're storing plain text

    const result = await pool.query(
      `INSERT INTO users (phone, password, role, delivery_guy_id)
       VALUES ($1, $2, $3, $4)
       RETURNING user_id, phone, role, created_at`,
      [phone, password, role, delivery_guy_id || null]
    );

    res.status(201).json({
      message: "User created successfully",
      user: result.rows[0],
    });
  } catch (error) {
    console.error("Create user error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { phone, role, delivery_guy_id } = req.body;

    // Check if user exists
    const userCheck = await pool.query(
      "SELECT * FROM users WHERE user_id = $1",
      [id]
    );

    if (userCheck.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const currentUser = userCheck.rows[0];

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramCounter = 1;

    if (phone) {
      // Check if phone already exists for another user
      const phoneCheck = await pool.query(
        "SELECT user_id FROM users WHERE phone = $1 AND user_id != $2",
        [phone, id]
      );

      if (phoneCheck.rows.length > 0) {
        return res.status(400).json({ message: "Phone number already in use" });
      }

      updates.push(`phone = $${paramCounter++}`);
      values.push(phone);
    }

    if (role) {
      // Validate role
      if (!["admin", "driver"].includes(role)) {
        return res
          .status(400)
          .json({ message: "Invalid role. Must be 'admin' or 'driver'" });
      }

      updates.push(`role = $${paramCounter++}`);
      values.push(role);
    }

    if (delivery_guy_id !== undefined) {
      if (delivery_guy_id === null) {
        updates.push(`delivery_guy_id = NULL`);
      } else {
        // Validate delivery guy exists
        const deliveryGuyCheck = await pool.query(
          "SELECT delivery_guy_id FROM delivery_guys WHERE delivery_guy_id = $1",
          [delivery_guy_id]
        );

        if (deliveryGuyCheck.rows.length === 0) {
          return res.status(404).json({ message: "Delivery person not found" });
        }

        // Check if delivery guy already has a user account
        const existingUserCheck = await pool.query(
          "SELECT user_id FROM users WHERE delivery_guy_id = $1 AND user_id != $2",
          [delivery_guy_id, id]
        );

        if (existingUserCheck.rows.length > 0) {
          return res.status(400).json({
            message: "This delivery person already has a user account",
          });
        }

        updates.push(`delivery_guy_id = $${paramCounter++}`);
        values.push(delivery_guy_id);
      }
    }

    if (updates.length === 0) {
      return res
        .status(400)
        .json({ message: "No valid fields provided for update" });
    }

    updates.push(`updated_at = $${paramCounter++}`);
    values.push(new Date());

    // Add user ID to values array
    values.push(id);

    const result = await pool.query(
      `UPDATE users
       SET ${updates.join(", ")}
       WHERE user_id = $${paramCounter}
       RETURNING user_id, phone, role, delivery_guy_id, updated_at`,
      values
    );

    res.json({
      message: "User updated successfully",
      user: result.rows[0],
    });
  } catch (error) {
    console.error("Update user error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user exists
    const userCheck = await pool.query(
      "SELECT * FROM users WHERE user_id = $1",
      [id]
    );

    if (userCheck.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    // Check if this is the last admin user
    if (userCheck.rows[0].role === "admin") {
      const adminCount = await pool.query(
        "SELECT COUNT(*) FROM users WHERE role = 'admin'"
      );

      if (parseInt(adminCount.rows[0].count) <= 1) {
        return res.status(400).json({
          message: "Cannot delete the last admin user",
        });
      }
    }

    // Delete user
    await pool.query("DELETE FROM users WHERE user_id = $1", [id]);

    res.json({ message: "User deleted successfully" });
  } catch (error) {
    console.error("Delete user error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const updateUserRole = async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;

    if (!role || !["admin", "driver"].includes(role)) {
      return res
        .status(400)
        .json({ message: "Valid role ('admin' or 'driver') is required" });
    }

    // Check if user exists
    const userCheck = await pool.query(
      "SELECT * FROM users WHERE user_id = $1",
      [id]
    );

    if (userCheck.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    // Check if this is the last admin user and we're trying to change role
    if (userCheck.rows[0].role === "admin" && role !== "admin") {
      const adminCount = await pool.query(
        "SELECT COUNT(*) FROM users WHERE role = 'admin'"
      );

      if (parseInt(adminCount.rows[0].count) <= 1) {
        return res.status(400).json({
          message: "Cannot change role of the last admin user",
        });
      }
    }

    // If changing to driver role, make sure delivery_guy_id is set
    if (role === "driver" && !userCheck.rows[0].deliveryguyid) {
      return res.status(400).json({
        message:
          "Cannot change role to driver without a delivery person assigned",
      });
    }

    const result = await pool.query(
      `UPDATE users
       SET role = $1, updated_at = NOW()
       WHERE user_id = $2
       RETURNING user_id, phone, role, updated_at`,
      [role, id]
    );

    res.json({
      message: "User role updated successfully",
      user: result.rows[0],
    });
  } catch (error) {
    console.error("Update user role error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const changePassword = async (req, res) => {
  try {
    const { id } = req.params;
    const { currentPassword, newPassword } = req.body;

    // In a real app, you'd require both current and new password
    // For simplicity in this example, we're only requiring new password

    if (!newPassword) {
      return res.status(400).json({ message: "New password is required" });
    }

    // Get user to verify if it exists and check current password
    const userCheck = await pool.query(
      "SELECT * FROM users WHERE user_id = $1",
      [id]
    );

    if (userCheck.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    // Check if the user is allowed to change this password
    const isOwnAccount = req.user.id === parseInt(id);
    const isAdmin = req.user.role === "admin";

    if (!isOwnAccount && !isAdmin) {
      return res.status(403).json({
        message: "You are not authorized to change this user's password",
      });
    }

    // If it's own account and not admin, verify current password
    if (isOwnAccount && !isAdmin) {
      if (!currentPassword) {
        return res
          .status(400)
          .json({ message: "Current password is required" });
      }

      // In a real app, you'd use bcrypt.compare
      if (currentPassword !== userCheck.rows[0].password) {
        return res
          .status(400)
          .json({ message: "Current password is incorrect" });
      }
    }

    // In a production app, you would hash the password
    // const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password
    await pool.query(
      `UPDATE users
       SET password = $1, updated_at = NOW()
       WHERE user_id = $2`,
      [newPassword, id]
    );

    res.json({ message: "Password changed successfully" });
  } catch (error) {
    console.error("Change password error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
