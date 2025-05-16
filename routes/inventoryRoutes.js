import express from "express";
import {
  getInventory,
  addInventory,
  deductInventory,
  getLowStockAlerts,
} from "../controllers/inventoryController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/", authenticate, getInventory);
router.post("/add", authenticate, authorize(["admin"]), addInventory);
router.post("/deduct", authenticate, authorize(["admin"]), deductInventory);
router.get("/low-stock", authenticate, getLowStockAlerts);

export default router;
