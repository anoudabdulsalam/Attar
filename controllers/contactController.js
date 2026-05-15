const ContactMessage = require("../models/ContactMessage");

const sendContactMessage = async (req, res) => {
  try {
    const { name, email, subject, message } = req.body;

    // Check required fields
    if (!name || !email || !subject || !message) {
      return res.status(400).json({
        message: "Name, email, subject, and message are required",
      });
    }

    const newMessage = new ContactMessage({
      name,
      email,
      subject,
      message,
    });

    await newMessage.save();

    res.status(201).json({
      message: "Contact message sent successfully",
      contact: newMessage,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

module.exports = {
  sendContactMessage,
};