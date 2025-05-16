import pool from "../config/database.js";

export const initializeSchema = async () => {
  try {
    // Create customers table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS customers (
        customer_id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        location VARCHAR(255),
        phone VARCHAR(20) NOT NULL UNIQUE,
        address TEXT,
        price DECIMAL(10,2) NOT NULL,
        points INTEGER DEFAULT 0,
        status VARCHAR(20) DEFAULT 'active',
        default_quantity INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create routes table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS routes (
        route_id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create route_customers junction table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS route_customers (
        route_customer_id SERIAL PRIMARY KEY,
        route_id INTEGER REFERENCES routes(route_id) ON DELETE CASCADE,
        customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(route_id, customer_id)
      )
    `);

    // Create delivery_guys table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS delivery_guys (
        delivery_guy_id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        phone VARCHAR(20) NOT NULL UNIQUE,
        address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create drives table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS drives (
        drive_id SERIAL PRIMARY KEY,
        delivery_guy_id INTEGER REFERENCES delivery_guys(delivery_guy_id),
        route_id INTEGER REFERENCES routes(route_id),
        stock INTEGER NOT NULL,
        sold INTEGER DEFAULT 0,
        returned INTEGER DEFAULT 0,
        remarks TEXT,
        start_time TIMESTAMP,
        end_time TIMESTAMP,
        total_amount DECIMAL(10,2) DEFAULT 0,
        status VARCHAR(20) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create payment_logs table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS payment_logs (
        payment_id SERIAL PRIMARY KEY,
        customer_id INTEGER REFERENCES customers(customer_id),
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        amount DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'completed',
        mode VARCHAR(20) NOT NULL,
        remarks TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create qr_codes table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS qr_codes (
        qr_id SERIAL PRIMARY KEY,
        code VARCHAR(255) NOT NULL UNIQUE,
        customer_id INTEGER REFERENCES customers(customer_id),
        status VARCHAR(20) DEFAULT 'active',
        activated_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create drive_customers_sales table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS drive_customers_sales (
        id SERIAL PRIMARY KEY,
        qr_id INTEGER REFERENCES qr_codes(qr_id),
        drive_id INTEGER REFERENCES drives(drive_id),
        customer_id INTEGER REFERENCES customers(customer_id),
        quantity INTEGER NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        total_amount DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'pending',
        sms_sent BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create drive_locations_log table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS drive_locations_log (
        drive_location_id SERIAL PRIMARY KEY,
        drive_id INTEGER REFERENCES drives(drive_id),
        location POINT NOT NULL,
        time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create outlets table
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

    // Create users table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        user_id SERIAL PRIMARY KEY,
        phone VARCHAR(20) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        role VARCHAR(20) NOT NULL,
        delivery_guy_id INTEGER REFERENCES delivery_guys(delivery_guy_id),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    console.log("Database schema initialized successfully");
  } catch (error) {
    console.error("Error initializing database schema:", error);
    throw error;
  }
};
