import express from "express";
import cors from "cors";
import { config } from "./config/config.js";
import { connectDB } from "./config/database.js";

// Import routes
import deliveryPersonRoutes from "./routes/deliveryPersonRoutes.js";
import authRoutes from "./routes/authRoutes.js";

// Initialize express app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use("/api/delivery-persons", deliveryPersonRoutes);
app.use("/api/auth", authRoutes);

// Health check route
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", message: "Server is running" });
});

// Start server
const PORT = config.port || 3000;

// Connect to database and start server
connectDB()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Database connection failed:", err);
    process.exit(1);
  });

export default app;
