import express from "express";
import {
  healthCheck,
  getVersion,
  submitFeedback,
  getSystemMetrics,
} from "../controllers/utilsController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/health", healthCheck);
router.get("/version", getVersion);
router.post("/feedback", authenticate, submitFeedback);
router.get("/metrics", authenticate, authorize(["admin"]), getSystemMetrics);

export default router;
