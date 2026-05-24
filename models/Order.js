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
    storeName: {
      type: String,
      trim: true,
    },
  },
  { _id: false }
);

const orderSchema = new mongoose.Schema(
  {
    orderNumber: {
      type: String,
      trim: true,
    },

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

    discount: {
      type: Number,
      default: 0,
    },

    expenses: {
      type: Number,
      default: 0,
    },

    paymentMethod: {
      type: String,
      default: "غير محدد",
    },

    paymentStatus: {
      type: String,
      enum: ["مدفوع", "قيد الانتظار", "غير مدفوع"],
      default: "قيد الانتظار",
    },

    status: {
      type: String,
      enum: ["قيد التحضير", "جاهز ومع شركة التوصيل", "تم الاستلام"],
      default: "قيد التحضير",
    },

    receivedAt: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true }
);

orderSchema.pre("save", function (next) {
  if (!this.orderNumber) {
    this.orderNumber = `INV-${Date.now().toString().slice(-6)}`;
  }
  next();
});

module.exports = mongoose.model("Order", orderSchema);