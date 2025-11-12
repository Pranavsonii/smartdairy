import express from "express";
import * as deliveryPersonController from "../controllers/deliveryPersonController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/", authenticate, deliveryPersonController.getDeliveryPersons);
router.get("/:id", authenticate, deliveryPersonController.getDeliveryPersonById);
router.post("/", authenticate, authorize(["admin"]), deliveryPersonController.createDeliveryPerson);
router.put("/:id", authenticate, authorize(["admin"]), deliveryPersonController.updateDeliveryPerson);
router.delete("/:id", authenticate, authorize(["admin"]), deliveryPersonController.deleteDeliveryPerson);
router.put("/:id/restore", authenticate, authorize(["admin"]), deliveryPersonController.restoreDeliveryPerson);
router.get("/:id/drives", authenticate, deliveryPersonController.getDeliveryPersonDrives);
router.get(
  "/:id/performance",
  authenticate,
  deliveryPersonController.getDeliveryPersonPerformance
);

export default router;
