import pool from "../config/database.js";
import { connectDB } from "../config/database.js";

const createTables = async () => {
  try {
    await connectDB();
    console.log("Connected to database");

    // Create outlets table
    console.log("Creating outlets table...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS outlets (
        outlet_id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        address TEXT,
        phone VARCHAR(20),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create delivery_guys table
    console.log("Creating delivery_guys table...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS delivery_guys (
        delivery_guy_id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        phone VARCHAR(15) NOT NULL UNIQUE,
        address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create users table
    console.log("Creating users table...");
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        user_id SERIAL PRIMARY KEY,
        delivery_guy_id INTEGER REFERENCES delivery_guys(delivery_guy_id) ON DELETE SET NULL,
        outlet_id INTEGER REFERENCES outlets(outlet_id) ON DELETE SET NULL,
        phone VARCHAR(15) NOT NULL UNIQUE,
        password VARCHAR(100) NOT NULL,
        role VARCHAR(20) NOT NULL DEFAULT 'delivery',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    console.log("Tables created successfully!");
    process.exit(0);
  } catch (error) {
    console.error("Error creating tables:", error);
    process.exit(1);
  }
};

createTables();
