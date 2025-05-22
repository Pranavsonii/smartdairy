import express from "express";
import {
  getQrCodes,
  getQrCodeById,
  generateQrCodes,
  assignQrToCustomer,
  updateQrCodeStatus,
  downloadQrCodes,
  replaceQrCode,
} from "../controllers/qrCodeController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/", authenticate, getQrCodes);
router.get("/download", authenticate, authorize(["admin"]), downloadQrCodes);
router.get("/:id", authenticate, getQrCodeById);
router.post("/generate", authenticate, authorize(["admin"]), generateQrCodes);
router.post(
  "/:code/assign",
  authenticate,
  authorize(["admin"]),
  assignQrToCustomer
);
router.put(
  "/:id/status",
  authenticate,
  authorize(["admin"]),
  updateQrCodeStatus
);
router.post("/:id/replace", authenticate, authorize(["admin"]), replaceQrCode);

export default router;
