const express = require("express");
const router = express.Router();

const {
  addNotification,
  getNotificationsByUserAndRole,
  markNotificationAsRead,
} = require("../controllers/notificationController");

router.post("/", addNotification);
router.get("/:userId/:role", getNotificationsByUserAndRole);
router.put("/:id/read", markNotificationAsRead);

module.exports = router;