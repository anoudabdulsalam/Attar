const express = require("express");
const router = express.Router();
const {
  addNotification,
  getNotificationsByUser,
  markNotificationAsRead,
} = require("../controllers/notificationController");

router.post("/", addNotification);
router.get("/:userId", getNotificationsByUser);
router.put("/:id/read", markNotificationAsRead);

module.exports = router;