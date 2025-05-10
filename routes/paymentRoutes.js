import express from "express";
import {
  getPayments,
  getPaymentById,
  createPayment,
  updatePayment,
  deletePayment,
  getOverdueAccounts,
  generateReceipt,
  sendReceipt,
} from "../controllers/paymentController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/", authenticate, getPayments);
router.get("/overdue", authenticate, getOverdueAccounts);
router.get("/:id", authenticate, getPaymentById);
router.post("/", authenticate, createPayment);
router.put("/:id", authenticate, authorize(["admin"]), updatePayment);
router.delete("/:id", authenticate, authorize(["admin"]), deletePayment);
router.post("/:id/receipt", authenticate, generateReceipt);
router.post("/:id/send-receipt", authenticate, sendReceipt);

export default router;
