import express from "express";
import {
  getDrives,
  getDriveById,
  createDrive,
  updateDrive,
  deleteDrive,
  getDriveDetails,
  assignDeliveryPersonToDrive,
  startDrive,
  endDrive,
  getDriveLocations,
  logDriveLocation,
  getDriveSummary,
  getDriveManifest,
} from "../controllers/driveController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/", authenticate, getDrives);
router.get("/:id", authenticate, getDriveById);
router.post("/", authenticate, authorize(["admin"]), createDrive);
router.put("/:id", authenticate, authorize(["admin"]), updateDrive);
router.delete("/:id", authenticate, authorize(["admin"]), deleteDrive);
router.get("/:id/details", authenticate, getDriveDetails);
router.post(
  "/:id/assign",
  authenticate,
  authorize(["admin"]),
  assignDeliveryPersonToDrive
);
router.post("/:id/start", authenticate, startDrive);
router.post("/:id/end", authenticate, endDrive);
router.get("/:id/locations", authenticate, getDriveLocations);
router.post("/:id/locations", authenticate, logDriveLocation);
router.get("/:id/summary", authenticate, getDriveSummary);
router.get("/:id/manifest", authenticate, getDriveManifest);

export default router;
