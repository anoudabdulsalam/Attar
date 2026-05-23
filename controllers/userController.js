const User = require("../models/User");

// Get user by ID
const getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select("-password");

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    res.status(200).json({
      message: "User fetched successfully",
      user,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

// Update user by ID
const updateUserById = async (req, res) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).select("-password");

    if (!updatedUser) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    res.status(200).json({
      message: "User updated successfully",
      user: updatedUser,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

//to gel all users
const getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select("-password");

    res.status(200).json({
      message: "Users fetched successfully",
      users,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const logInteraction = async (req, res) => {
  try {
    const { herbId, type } = req.body;
    const userId = req.params.id;

    if (!herbId || !type) {
      return res.status(400).json({ message: "herbId and type are required" });
    }

    let weight = 1;
    if (type === "search") weight = 2;
    if (type === "purchase") weight = 5;
    if (type === "click") weight = 1;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const prefIndex = user.herbPreferences.findIndex(p => p.herbId === herbId);
    if (prefIndex !== -1) {
      user.herbPreferences[prefIndex].score += weight;
    } else {
      user.herbPreferences.push({ herbId, score: weight });
    }

    await user.save();

    res.status(200).json({
      message: "Interaction logged successfully",
      herbPreferences: user.herbPreferences
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

module.exports = {
  getUserById,
  updateUserById,
  getAllUsers,
  logInteraction,
};