import { config } from "../config/config.js";
import { connectDB } from "../config/database.js";
import pool from "../config/database.js";
import bcrypt from "bcrypt";
import readline from "readline";

// Create readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Function to prompt user for input
const promptUser = (question) => {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
};

// Simplified password input - no masking but clear instructions
const promptPassword = (question) => {
  return new Promise((resolve) => {
    console.log("\n" + "=".repeat(50));
    console.log("⚠️  PASSWORD INPUT - Characters will be visible!");
    console.log("⚠️  Make sure no one is looking at your screen!");
    console.log("=".repeat(50));

    rl.question(question, (answer) => {
      // Clear the screen after password input (Windows compatible)
      process.stdout.write('\x1Bc'); // Clear screen
      console.log("Password entered successfully (hidden from display)\n");
      resolve(answer);
    });
  });
};

// Alternative: Use a third-party package for better password input
// You can also install 'read' package: npm install read
// Then use:
/*
import read from 'read';

const promptPassword = (question) => {
  return new Promise((resolve, reject) => {
    read({
      prompt: question,
      silent: true,
      replace: '*'
    }, (err, password) => {
      if (err) reject(err);
      else resolve(password);
    });
  });
};
*/

const createAdminAccount = async () => {
  try {
    console.log("=== Smart Dairy Admin Account Creator ===\n");

    // Get admin details from user
    const phone = await promptUser("Enter admin phone number: ");

    if (!phone || phone.length < 10) {
      throw new Error("Please enter a valid phone number (minimum 10 digits)");
    }

    // Check if phone already exists
    const phoneCheck = await pool.query(
      "SELECT user_id, role FROM users WHERE phone = $1",
      [phone]
    );

    if (phoneCheck.rows.length > 0) {
      const existingUser = phoneCheck.rows[0];
      if (existingUser.role === 'admin') {
        throw new Error(`Admin account with phone ${phone} already exists!`);
      } else {
        throw new Error(`User account with phone ${phone} already exists with role: ${existingUser.role}`);
      }
    }

    const password = await promptPassword("Enter admin password: ");

    if (!password || password.length < 6) {
      throw new Error("Password must be at least 6 characters long");
    }

    const confirmPassword = await promptPassword("Confirm admin password: ");

    if (password !== confirmPassword) {
      throw new Error("Passwords do not match!");
    }

    // Handle outlet selection/creation
    let outlet_id;
    const outletCheck = await pool.query(
      "SELECT outlet_id, name, address, phone FROM outlets ORDER BY outlet_id"
    );

    if (outletCheck.rows.length === 0) {
      console.log("\nNo outlets found. You need to create a new outlet.");
      outlet_id = await createNewOutlet(phone);
    } else {
      console.log("\n=== Outlet Selection ===");
      console.log("Existing outlets:");
      console.log("ID | Name | Address | Phone");
      console.log("---|------|---------|-------");

      outletCheck.rows.forEach((outlet, index) => {
        console.log(`${outlet.outlet_id}  | ${outlet.name} | ${outlet.address} | ${outlet.phone}`);
      });

      console.log("\nOptions:");
      console.log("1. Select existing outlet");
      console.log("2. Create new outlet");

      const choice = await promptUser("\nEnter your choice (1 or 2): ");

      if (choice === "1") {
        outlet_id = await selectExistingOutlet(outletCheck.rows);
      } else if (choice === "2") {
        outlet_id = await createNewOutlet(phone);
      } else {
        throw new Error("Invalid choice. Please enter 1 or 2.");
      }
    }

    // Hash the password
    console.log("\nCreating admin account...");
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create admin user
    const adminResult = await pool.query(
      "INSERT INTO users (phone, password, role, outlet_id) VALUES ($1, $2, $3, $4) RETURNING user_id, phone, role",
      [phone, hashedPassword, "admin", outlet_id]
    );

    const adminUser = adminResult.rows[0];

    console.log("\n✓ Admin account created successfully!");
    console.log("=====================================");
    console.log(`User ID: ${adminUser.user_id}`);
    console.log(`Phone: ${adminUser.phone}`);
    console.log(`Role: ${adminUser.role}`);
    console.log(`Outlet ID: ${outlet_id}`);
    console.log("=====================================");
    console.log("\nYou can now login with these credentials.");
    console.log("Please keep this information secure!");

  } catch (error) {
    console.error("\n❌ Error creating admin account:", error.message);
    throw error;
  }
};

// Function to select existing outlet
const selectExistingOutlet = async (outlets) => {
  try {
    const outletIds = outlets.map(outlet => outlet.outlet_id.toString());

    while (true) {
      const selectedId = await promptUser(`\nEnter outlet ID (${outletIds.join(', ')}): `);

      if (outletIds.includes(selectedId)) {
        const selectedOutlet = outlets.find(outlet => outlet.outlet_id.toString() === selectedId);
        console.log(`✓ Selected outlet: ${selectedOutlet.name} (ID: ${selectedId})`);
        return parseInt(selectedId);
      } else {
        console.log("❌ Invalid outlet ID. Please select from the available outlets.");
      }
    }
  } catch (error) {
    throw new Error(`Error selecting outlet: ${error.message}`);
  }
};

// Function to create new outlet
const createNewOutlet = async (defaultPhone) => {
  try {
    console.log("\n=== Creating New Outlet ===");

    const outletName = await promptUser("Enter outlet name: ");
    if (!outletName.trim()) {
      throw new Error("Outlet name is required");
    }

    const outletAddress = await promptUser("Enter outlet address: ");
    if (!outletAddress.trim()) {
      throw new Error("Outlet address is required");
    }

    const outletPhone = await promptUser(`Enter outlet phone (or press Enter to use ${defaultPhone}): `);
    const finalPhone = outletPhone.trim() || defaultPhone;

    // Check if outlet phone already exists
    const phoneCheck = await pool.query(
      "SELECT outlet_id FROM outlets WHERE phone = $1",
      [finalPhone]
    );

    if (phoneCheck.rows.length > 0) {
      const useAnyway = await promptUser(`⚠️  Phone ${finalPhone} already exists for another outlet. Continue anyway? (y/n): `);
      if (useAnyway.toLowerCase() !== 'y' && useAnyway.toLowerCase() !== 'yes') {
        throw new Error("Outlet creation cancelled due to duplicate phone number");
      }
    }

    const outletResult = await pool.query(
      "INSERT INTO outlets (name, address, phone) VALUES ($1, $2, $3) RETURNING outlet_id, name",
      [outletName.trim(), outletAddress.trim(), finalPhone]
    );

    const newOutlet = outletResult.rows[0];
    console.log(`✓ New outlet created: ${newOutlet.name} (ID: ${newOutlet.outlet_id})`);

    return newOutlet.outlet_id;
  } catch (error) {
    throw new Error(`Error creating outlet: ${error.message}`);
  }
};

// Main execution function
const init = async () => {
  try {
    console.log("Connecting to database...");
    await connectDB();
    console.log("✓ Database connected successfully!\n");

    await createAdminAccount();

    console.log("\n✓ Admin account creation completed successfully!");

  } catch (error) {
    console.error("\n❌ Admin account creation failed:", error.message);
  } finally {
    rl.close();
    process.exit(0);
  }
};

// Execute the script
init();