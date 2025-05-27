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

router.get("/", (req, res) => {
  res.status(200).json({ status: "ok", message: "Auth routes are working" });
});

export default router;
