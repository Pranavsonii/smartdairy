import express from "express";
import { config } from "./config/config.js";
import { connectDB } from "./config/database.js";
import path from "path";

// Import routes
import authRoutes from "./routes/authRoutes.js";
import customerRoutes from "./routes/customerRoutes.js";
import routeRoutes from "./routes/routeRoutes.js";
import driveRoutes from "./routes/driveRoutes.js";
import paymentRoutes from "./routes/paymentRoutes.js";
import qrCodeRoutes from "./routes/qrCodeRoutes.js";
import driveExecutionRoutes from "./routes/driveExecutionRoutes.js";
import reportRoutes from "./routes/reportRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import deliveryPersonRoutes from "./routes/deliveryPersonRoutes.js";
import inventoryRoutes from "./routes/inventoryRoutes.js";
import mapRoutes from "./routes/mapRoutes.js";
// import analyticsRoutes from "./routes/analyticsRoutes.js";
// import notificationRoutes from "./routes/notificationRoutes.js";
// import settingsRoutes from "./routes/settingsRoutes.js";
// import syncRoutes from "./routes/syncRoutes.js";
// import exportRoutes from "./routes/exportRoutes.js";
import utilsRoutes from "./routes/utilsRoutes.js";

// Initialize express app
const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Connect to database
connectDB();

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/customers", customerRoutes);
app.use("/api/routes", routeRoutes);
app.use("/api/drives", driveRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/qr-codes", qrCodeRoutes);
app.use("/api/drive-execution", driveExecutionRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/users", userRoutes);
app.use("/api/delivery-persons", deliveryPersonRoutes);
app.use("/api/inventory", inventoryRoutes);
app.use("/api/map", mapRoutes);
// app.use("/api/analytics", analyticsRoutes);
// app.use("/api/notifications", notificationRoutes);
// app.use("/api/settings", settingsRoutes);
// app.use("/api/sync", syncRoutes);
// app.use("/api/export", exportRoutes);
app.use("/api/utils", utilsRoutes);

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));
app.use('/public', express.static(path.join(process.cwd(), 'public')));
app.use('/public/uploads', express.static(path.join(process.cwd(), 'uploads')));


// admin account creation
app.use("/api/admin", (req, res) => {
  // This is a placeholder for admin account creation logic


  // In a real application, you would implement the logic to create an admin account here
  res.status(200).json({ message: "Admin account creation endpoint" });
});




// Start server
const PORT = config.port || 3005;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
