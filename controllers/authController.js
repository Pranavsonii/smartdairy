import pool from "../config/database.js";
import jwt from "jsonwebtoken";
import { config } from "../config/config.js";
import bcrypt from "bcrypt";
// Add this line if you want to use crypto:
import crypto from "crypto";

export const login = async (req, res) => {
  try {
    const { phone, password } = req.body;

    // Check if user exists
    const userResult = await pool.query(
      "SELECT user_id, phone, password, role FROM users WHERE phone = $1",
      [phone]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const user = userResult.rows[0];

    // If using bcrypt (recommended):
    const isMatch = await bcrypt.compare(password, user.password);

    // If you need to use crypto (replace line 32):
    // const hashedPassword = crypto.createHash('sha256').update(password).digest('hex');
    // const isMatch = hashedPassword === user.password;

    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    console.log(user);

    // Generate JWT token
    const token = jwt.sign(
      { user_id: user.user_id, role: user.role },
      config.jwt.secret,
      { expiresIn: config.jwt.expiresIn }
    );

    res.json({
      token,
      user: {
        user_id: user.user_id,
        phone: user.phone,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const logout = (req, res) => {
  // JWT is stateless, so we don't need to invalidate the token on the server
  // Client should remove the token from storage
  res.json({ message: "Logout successful" });
};

export const resetPassword = async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({ message: "Phone number is required" });
    }

    // Check if user exists
    const result = await pool.query(
      "SELECT user_id FROM users WHERE phone = $1",
      [phone]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    // In a real app, you would:
    // 1. Generate a reset token
    // 2. Store it with an expiration time
    // 3. Send it via SMS

    res.json({
      message: "Password reset instructions sent",
    });
  } catch (error) {
    console.error("Password reset error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getProfile = async (req, res) => {
  try {

    const user_id = req.user.user_id;

    console.log("User ID from token:", req.user);

    const result = await pool.query(
      "SELECT user_id, phone, role FROM users WHERE user_id = $1",
      [user_id]
    );

    console.log("Query result:", result);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const user = result.rows[0];

    res.json({
      user: {
        user_id: user.user_id,
        phone: user.phone,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
