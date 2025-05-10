import express from "express";
import {
  getRoutes,
  getRouteById,
  createRoute,
  updateRoute,
  deleteRoute,
  addCustomersToRoute,
  removeCustomerFromRoute,
  getRouteCustomers,
} from "../controllers/routeController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/", authenticate, getRoutes);
router.get("/:id", authenticate, getRouteById);
router.post("/", authenticate, authorize(["admin"]), createRoute);
router.put("/:id", authenticate, authorize(["admin"]), updateRoute);
router.delete("/:id", authenticate, authorize(["admin"]), deleteRoute);
router.post(
  "/:id/customers",
  authenticate,
  authorize(["admin"]),
  addCustomersToRoute
);
router.delete(
  "/:id/customers/:customer_id",
  authenticate,
  authorize(["admin"]),
  removeCustomerFromRoute
);
router.get("/:id/customers", authenticate, getRouteCustomers);

export default router;
