const mongoose = require("mongoose");

const orderItemSchema = new mongoose.Schema(
  {
    herbId: {
      type: String,
      required: true,
      trim: true,
    },
    herbName: {
      type: String,
      required: true,
      trim: true,
    },
    imageUrl: {
      type: String,
      trim: true,
    },
    quantity: {
      type: Number,
      required: true,
      default: 1,
    },
    price: {
      type: Number,
      required: true,
      default: 0,
    },
  },
  { _id: false }
);

const orderSchema = new mongoose.Schema(
  {
    buyerId: {
      type: String,
      required: true,
      trim: true,
    },
    buyerName: {
      type: String,
      trim: true,
    },
    buyerRole: {
      type: String,
      trim: true,
    },

    storeOwnerId: {
      type: String,
      required: true,
      trim: true,
    },
    storeName: {
      type: String,
      trim: true,
    },

    items: {
      type: [orderItemSchema],
      required: true,
      default: [],
    },

    totalPrice: {
      type: Number,
      required: true,
      default: 0,
    },

    status: {
      type: String,
      enum: ["قيد التحضير", "جاهز ومع شركة التوصيل", "تم الاستلام"],
      default: "قيد التحضير",
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Order", orderSchema);