import pool from "../config/database.js";

const addIsActiveToDeliveryGuys = async () => {
    try {
        console.log("Adding is_active column to delivery_guys table...");

        // Add is_active column
        await pool.query(`
      ALTER TABLE delivery_guys
      ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true
    `);

        // Set existing records to active
        await pool.query(`
      UPDATE delivery_guys
      SET is_active = true
      WHERE is_active IS NULL
    `);

        console.log("Successfully added is_active column to delivery_guys table");
        process.exit(0);
    } catch (error) {
        console.error("Error adding is_active column:", error);
        process.exit(1);
    }
};

addIsActiveToDeliveryGuys();
