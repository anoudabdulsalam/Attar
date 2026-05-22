const mongoose = require("mongoose");

const herbSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    scientificName: {
      type: String,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    benefits: {
      type: String,
      trim: true,
    },
    usageMethod: {
      type: String,
      trim: true,
    },
    season: {
      type: String,
      trim: true,
    },
    category: {
      type: String,
      trim: true,
    },
    imageUrl: {
      type: String,
      trim: true,
    },
    price: {
      type: Number,
      default: 0,
    },
    quantity: {
      type: Number,
      default: 0,
    },
    storeOwnerId: {
      type: String,
      trim: true,
    },
    storeName: {
      type: String,
      trim: true,
    },

    comments: [
  {
    userId: {
      type: String,
      trim: true,
    },
    userName: {
      type: String,
      trim: true,
    },
    userRole: {
      type: String,
      trim: true,
    },
    text: {
      type: String,
      required: true,
      trim: true,
    },
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
],
    onSale: {
      type: Boolean,
      default: false,
    },
    salePrice: {
      type: Number,
      default: null,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Herb", herbSchema);
