const express = require("express");
const router = express.Router();
const {
  getUserById,
  updateUserById,
  getAllUsers,
  logInteraction,
} = require("../controllers/userController");

router.get("/", getAllUsers);
router.get("/:id", getUserById);
router.put("/:id", updateUserById);
router.post("/:id/interact", logInteraction);

module.exports = router;