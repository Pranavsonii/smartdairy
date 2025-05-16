import { config } from "../config/config.js";
import { connectDB } from "../config/database.js";
// Comment out this line
import { initializeSchema } from "../models/schemaInit.js";
import pool from "../config/database.js";
import bcrypt from "bcrypt";

const createAdminAndOutlet = async () => {
  try {
    // Check if admin exists
    const adminCheck = await pool.query(
      "SELECT 'user_id' FROM users WHERE role = 'admin' LIMIT 1"
    );

    if (adminCheck.rows.length > 0) {
      console.log("Admin user already exists. Skipping creation.");
      return;
    }

    // Create default outlet
    const outletResult = await pool.query(
      "INSERT INTO outlets (name, address, phone) VALUES ($1, $2, $3) RETURNING 'outlet_id'",
      ["Main Outlet", "123 Main Street", "1234567890"]
    );

    const outlet_id = outletResult.rows[0].outlet_id;
    console.log(`Default outlet created with ID: ${outlet_id}`);

    // Create admin user with hashed password using proper bcrypt
    const password = "admin123"; // Default password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    await pool.query(
      "INSERT INTO users (phone, password, role, outlet_id) VALUES ($1, $2, $3, $4)",
      ["1234567890", hashedPassword, "admin", outlet_id]
    );

    console.log(
      "Default admin user created and linked to outlet. Phone: 1234567890, Password: admin123"
    );
    console.log("Please change the admin password after logging in!");
  } catch (error) {
    console.error("Error creating admin user and outlet:", error);
    throw error;
  }
};

// Main execution function
const init = async () => {
  try {
    await connectDB();

    // Comment out this line
    // await initializeSchema();

    await createAdminAndOutlet();
    console.log("Database initialization completed successfully!");
    process.exit(0);
  } catch (error) {
    console.error("Database initialization failed:", error);
    process.exit(1);
  }
};

// Execute the initialization
init();
