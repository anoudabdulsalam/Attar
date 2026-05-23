const express = require("express");
const router = express.Router();
const {
  adminLogin,
  getAllUsers,
  deleteUser,
  getStoreStats,
  getMessages,
} = require("../controllers/adminController");

router.post("/login", adminLogin);
router.get("/users", getAllUsers);
router.delete("/users/:id", deleteUser);
router.get("/stats", getStoreStats);
router.get("/messages", getMessages);

module.exports = router;
