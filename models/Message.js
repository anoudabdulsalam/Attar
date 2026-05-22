const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema(
  {
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Conversation",
      required: true,
    },
    senderId: { type: String, required: true },
    senderRole: { type: String, required: true },
    receiverId: { type: String, required: true },
    receiverRole: { type: String, required: true },

    type: {
      type: String,
      enum: ["text", "post"],
      default: "text",
    },

    text: {
      type: String,
      default: "",
    },

    herb: {
      type: Object,
      default: null,
    },

    isRead: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Message", messageSchema);