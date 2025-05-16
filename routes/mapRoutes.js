import express from "express";
import {
  getRouteOptimization,
  getDistanceMatrix,
  geocodeAddress,
  reverseGeocode,
} from "../controllers/mapController.js";
import { authenticate } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/route-optimization/:route_id", authenticate, getRouteOptimization);
router.get("/distance-matrix", authenticate, getDistanceMatrix);
router.get("/geocode/:address", authenticate, geocodeAddress);
router.get("/reverse-geocode/:lat/:lng", authenticate, reverseGeocode);

export default router;
