const express = require("express");
const router = express.Router();

const Conversation = require("../models/Conversation");
const Message = require("../models/Message");

router.post("/conversation", async (req, res) => {
  try {
    const { user1Id, user1Role, user2Id, user2Role, chatName } = req.body;

    const finalChatName = chatName || user2Id;
    const chatKey = [user1Id, user2Id].sort().join("_");

    let conversation = await Conversation.findOne({ chatKey });

    if (!conversation) {
      conversation = await Conversation.create({
        chatKey,
        chatName: finalChatName,
        participants: [
          { userId: user1Id, role: user1Role },
          { userId: user2Id, role: user2Role },
        ],
      });
    }

    res.status(200).json(conversation);
  } catch (error) {
    res.status(500).json({
      message: "Error creating conversation",
      error: error.message,
    });
  }
});

router.post("/message", async (req, res) => {
  try {
    const {
      conversationId,
      senderId,
      senderRole,
      receiverId,
      receiverRole,
      text,
      type,
      herb,
    } = req.body;

    const finalType = type || "text";

    const message = await Message.create({
      conversationId,
      senderId,
      senderRole,
      receiverId,
      receiverRole,
      text: text || "",
      type: finalType,
      herb: herb || null,
    });

    await Conversation.findByIdAndUpdate(conversationId, {
      lastMessage: finalType === "post" ? "تم إرسال عشبة" : text,
      lastMessageAt: new Date(),
    });

    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({
      message: "Error sending message",
      error: error.message,
    });
  }
});

router.get("/messages/:conversationId", async (req, res) => {
  try {
    const messages = await Message.find({
      conversationId: req.params.conversationId,
    }).sort({ createdAt: 1 });

    res.status(200).json(messages);
  } catch (error) {
    res.status(500).json({
      message: "Error getting messages",
      error: error.message,
    });
  }
});

router.get("/conversations/:userId", async (req, res) => {
  try {
    const userId = req.params.userId;

    const conversations = await Conversation.find({
      "participants.userId": userId,
    }).sort({ lastMessageAt: -1 });

    const result = await Promise.all(
      conversations.map(async (conv) => {
        const unreadCount = await Message.countDocuments({
          conversationId: conv._id,
          receiverId: userId,
          isRead: false,
        });

        return {
          ...conv.toObject(),
          unreadCount,
        };
      })
    );

    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({
      message: "Error getting conversations",
      error: error.message,
    });
  }
});

router.put("/messages/read/:conversationId/:userId", async (req, res) => {
  try {
    await Message.updateMany(
      {
        conversationId: req.params.conversationId,
        receiverId: req.params.userId,
      },
      { isRead: true }
    );

    res.status(200).json({ message: "Messages marked as read" });
  } catch (error) {
    res.status(500).json({
      message: "Error marking messages as read",
      error: error.message,
    });
  }
});

module.exports = router;