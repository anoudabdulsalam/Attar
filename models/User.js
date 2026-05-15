const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },

    password: {
      type: String,
      required: true,
    },

    role: {
      type: String,
      enum: ["customer", "store_owner", "herbal_expert"],
      required: true,
    },

    fullName: {
      type: String,
      trim: true,
    },

    age: {
      type: Number,
    },

    ownerName: {
      type: String,
      trim: true,
    },

    storeName: {
      type: String,
      trim: true,
    },

    storeLocation: {
      type: String,
      trim: true,
    },

    yearsOfExperience: {
      type: Number,
    },

    certificateUrl: {
      type: String,
      trim: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);