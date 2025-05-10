import express from "express";
import {
  login,
  logout,
  resetPassword,
  getProfile,
} from "../controllers/authController.js";
import { authenticate } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.post("/login", login);
router.post("/logout", authenticate, logout);
router.post("/reset-password", resetPassword);
router.get("/me", authenticate, getProfile);

export default router;
