const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true },
    targetRole: {
      type: String,
      enum: ["customer", "herbal_expert", "expert", "store_owner"],
      required: true,
    },
    title: { type: String, required: true },
    body: { type: String, required: true },
    type: { type: Number, default: 1 },
    herbName: { type: String, default: "" },
    imageUrl: { type: String, default: "" },
    storeName: { type: String, default: "" },
    price: { type: String, default: "" },
    originalPrice: { type: String, default: "" },
    offerPrice: { type: String, default: "" },
    senderName: { type: String, default: "" },
    herbPayload: { type: Object, default: null },
    isRead: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Notification", notificationSchema);