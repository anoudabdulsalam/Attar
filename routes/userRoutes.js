const express = require("express");
const router = express.Router();
const {
  getUserById,
  updateUserById,
  getAllUsers,
} = require("../controllers/userController");

router.get("/", getAllUsers);
router.get("/:id", getUserById);
router.put("/:id", updateUserById);


module.exports = router;