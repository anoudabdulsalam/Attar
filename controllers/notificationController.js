const Notification = require("../models/Notification");

const addNotification = async (req, res) => {
  try {
    const notification = await Notification.create(req.body);
    res.status(201).json({ message: "Notification added", notification });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

const getNotificationsByUserAndRole = async (req, res) => {
  try {
    const { userId, role } = req.params;

    const notifications = await Notification.find({
      userId: userId,
      targetRole: role,
    }).sort({ createdAt: -1 });

    res.status(200).json({ notifications });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

const markNotificationAsRead = async (req, res) => {
  try {
    const notification = await Notification.findByIdAndUpdate(
      req.params.id,
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: "Notification not found" });
    }

    res.status(200).json({ notification });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

module.exports = {
  addNotification,
  getNotificationsByUserAndRole,
  markNotificationAsRead,
};