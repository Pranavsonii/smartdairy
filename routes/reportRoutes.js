import express from "express";
import {
  getCustomersReport,
  getPaymentsReport,
  getRoutesReport,
  getDrivesReport,
  getCustomReport,
} from "../controllers/reportController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get(
  "/customers",
  authenticate,
  authorize(["admin"]),
  getCustomersReport
);
router.get("/payments", authenticate, authorize(["admin"]), getPaymentsReport);
router.get("/routes", authenticate, authorize(["admin"]), getRoutesReport);
router.get("/drives", authenticate, authorize(["admin"]), getDrivesReport);
router.get("/custom", authenticate, authorize(["admin"]), getCustomReport);

export default router;
