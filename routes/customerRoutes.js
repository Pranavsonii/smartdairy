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
  getCustomerRoutes
} from "../controllers/customerController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/", authenticate, getCustomers);
router.get("/:id", authenticate, getCustomerById);
router.post("/", authenticate, authorize(["admin"]), createCustomer);
router.put("/:id", authenticate, authorize(["admin"]), updateCustomer);
router.delete("/:id", authenticate, authorize(["admin"]), deleteCustomer);
router.get("/:id/points", authenticate, getCustomerPoints);
router.post("/:id/points", authenticate, addCustomerPoints);
router.put("/:id/points/deduct", authenticate, deductCustomerPoints);
router.get("/:id/payment-logs", authenticate, getCustomerPaymentLogs);
router.get("/:id/routes", authenticate, getCustomerRoutes);

export default router;
