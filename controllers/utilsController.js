import pool from "../config/database.js";
import os from "os";
import version from "../package.json" with { type: "json" };

export const healthCheck = async (req, res) => {
  try {
    // Check database connection
    const dbResult = await pool.query("SELECT 1");

    const health = {
      status: "UP",
      timestamp: new Date(),
      database: dbResult.rows.length === 1 ? "UP" : "DOWN",
      api: "UP",
    };

    res.json(health);
  } catch (error) {
    console.error("Health check error:", error);
    res.status(500).json({
      status: "DOWN",
      timestamp: new Date(),
      database: "DOWN",
      api: "UP",
      error: error.message,
    });
  }
};

export const getVersion = (req, res) => {
  try {
    res.json({
      version,
      environment: process.env.NODE_ENV || "development",
      apiServerTime: new Date(),
    });
  } catch (error) {
    console.error("Get version error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const submitFeedback = async (req, res) => {
  try {
    const { message, type, category } = req.body;
    const user_id = req.user.id;

    if (!message) {
      return res.status(400).json({ message: "Feedback message is required" });
    }

    // In a real application, you would store the feedback in a database table
    // For this example, we'll just log it
    console.log(`Feedback received from user ${user_id}:`, {
      message,
      type: type || "general",
      category: category || "other",
    });

    res.json({
      message: "Feedback submitted successfully",
      feedbackId: `FB-${Date.now().toString().substring(5)}`,
    });
  } catch (error) {
    console.error("Submit feedback error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getSystemMetrics = async (req, res) => {
  try {
    // Get database metrics
    const dbMetrics = await pool.query(`
      SELECT
        (SELECT COUNT(*) FROM customers) as customerCount,
        (SELECT COUNT(*) FROM users) as userCount,
        (SELECT COUNT(*) FROM routes) as routeCount,
        (SELECT COUNT(*) FROM drives) as driveCount,
        (SELECT COUNT(*) FROM drives WHERE status = 'ongoing') as activeDrivers,
        (SELECT COUNT(*) FROM payment_logs) as paymentCount,
        (SELECT COUNT(*) FROM qr_codes) as qrCodeCount
    `);

    // Get system metrics
    const systemMetrics = {
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      cpu: os.cpus().length,
      freeMemory: os.freemem(),
      totalMemory: os.totalmem(),
      platform: os.platform(),
      architecture: os.arch(),
    };

    res.json({
      database: dbMetrics.rows[0],
      system: systemMetrics,
    });
  } catch (error) {
    console.error("Get system metrics error:", error);
    res.status(500).json({ message: "Server error" });
  }
};
