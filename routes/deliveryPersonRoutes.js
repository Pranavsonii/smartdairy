import express from "express";
import * as deliveryPersonController from "../controllers/deliveryPersonController.js";

const router = express.Router();

router.get("/", deliveryPersonController.getDeliveryPersons);
router.get("/:id", deliveryPersonController.getDeliveryPersonById);
router.post("/", deliveryPersonController.createDeliveryPerson);
router.put("/:id", deliveryPersonController.updateDeliveryPerson);
router.delete("/:id", deliveryPersonController.deleteDeliveryPerson);
router.get("/:id/drives", deliveryPersonController.getDeliveryPersonDrives);
router.get(
  "/:id/performance",
  deliveryPersonController.getDeliveryPersonPerformance
);

export default router;
