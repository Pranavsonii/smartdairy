import express from "express";
import {
  getUsers,
  createUser,
  getUserById,
  updateUser,
  deleteUser,
  updateUserRole,
  changePassword,
} from "../controllers/userController.js";
import { authenticate, authorize } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/", authenticate, authorize(["admin"]), getUsers);
router.post("/", authenticate, authorize(["admin"]), createUser);
router.get("/:id", authenticate, authorize(["admin"]), getUserById);
router.put("/:id", authenticate, authorize(["admin"]), updateUser);
router.delete("/:id", authenticate, authorize(["admin"]), deleteUser);
router.put("/:id/role", authenticate, authorize(["admin"]), updateUserRole);
router.put("/:id/password", authenticate, changePassword);

export default router;
