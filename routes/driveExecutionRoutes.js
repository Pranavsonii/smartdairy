import express from "express";
import {
  getDriveExecution,
  recordSale,
  skipCustomer,
  scanQrCode,
  getDriveProgress,
  reconcileDrive,
} from "../controllers/driveExecutionController.js";
import { authenticate } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/:id", authenticate, getDriveExecution);
router.post("/:id/sales", authenticate, recordSale);
router.post("/:id/skip-customer", authenticate, skipCustomer);
router.post("/:id/scan", authenticate, scanQrCode);
router.get("/:id/progress", authenticate, getDriveProgress);
router.post("/:id/reconcile", authenticate, reconcileDrive);

export default router;
