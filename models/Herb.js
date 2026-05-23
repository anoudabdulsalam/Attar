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
    likes: [{ type: String }],
    replies: [
      {
        userId: { type: String, required: true },
        userName: { type: String, required: true },
        userRole: { type: String, required: true },
        text: { type: String, required: true, trim: true },
        createdAt: { type: Date, default: Date.now },
      },
    ],
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
    saleUpdatedAt: {
      type: Date,
      default: null,
    },
    salePrice: {
      type: Number,
      default: null,
    },
    ratings: [
      {
        userId: { type: String, required: true },
        rating: { type: Number, required: true, min: 1, max: 5 },
      },
    ],
    salesCount: {
      type: Number,
      default: 0,
    },
    averageRating: {
      type: Number,
      default: 1,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Herb", herbSchema);
