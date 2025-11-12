import express from "express";
import {
  getCustomers,
  getCustomerById,
  createCustomer,
  updateCustomer,
  deleteCustomer,
  getCustomerPoints,
  addCustomerPoints,
  deductCustomerPoints,
  getCustomerPaymentLogs,
  getCustomerRoutes,
  getCustomerTransactions,
  updateTransaction,
  getTransactionById
} from "../controllers/customerController.js";
import {
  uploadCustomerPhoto,
  handleUploadError
} from "../middlewares/uploadMiddleware.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

// PUT SPECIFIC ROUTES FIRST (before /:id route)
router.get("/", authenticate, getCustomers);
router.get("/transactions", authenticate, getCustomerTransactions);           // ← Move this UP
router.get("/transactions/:transactionId", authenticate, getTransactionById); // ← Move this UP

// THEN put the generic /:id route
router.get("/:id", authenticate, getCustomerById);                           // ← Move this DOWN

// Rest of your routes
router.post("/", authenticate, authorize(["admin"]), uploadCustomerPhoto, handleUploadError, createCustomer);
router.put("/:id", authenticate, authorize(["admin"]), uploadCustomerPhoto, handleUploadError, updateCustomer);
router.delete("/:id", authenticate, authorize(["admin"]), deleteCustomer);
router.get("/:id/points", authenticate, getCustomerPoints);
router.post("/:id/points", authenticate, addCustomerPoints);
router.put("/:id/points/deduct", authenticate, deductCustomerPoints);
router.get("/:id/payment-logs", authenticate, getCustomerPaymentLogs);
router.get("/:id/routes", authenticate, getCustomerRoutes);

// Transaction editing routes
router.put("/:customerId/transactions/:transactionId", authenticate, updateTransaction);

export default router;
