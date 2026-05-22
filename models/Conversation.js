const mongoose = require("mongoose");

const conversationSchema = new mongoose.Schema(
  {
    chatKey: {
      type: String,
      required: true,
      unique: true,
    },

    chatName: {
      type: String,
      required: true,
    },

    participants: [
      {
        userId: {
          type: String,
          required: true,
        },
        role: {
          type: String,
          required: true,
        },
      },
    ],

    lastMessage: {
      type: String,
      default: "",
    },

    lastMessageAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Conversation", conversationSchema);