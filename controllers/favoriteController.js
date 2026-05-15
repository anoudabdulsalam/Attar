const Favorite = require("../models/Favorite");

// Add herb to favorites
const addFavorite = async (req, res) => {
  try {
    const { userId, herbId } = req.body;

    if (!userId || !herbId) {
      return res.status(400).json({
        message: "userId and herbId are required",
      });
    }

    const existingFavorite = await Favorite.findOne({ userId, herbId });

    if (existingFavorite) {
      return res.status(400).json({
        message: "This herb is already in favorites",
      });
    }

    const newFavorite = new Favorite({
      userId,
      herbId,
    });

    await newFavorite.save();

    res.status(201).json({
      message: "Favorite added successfully",
      favorite: newFavorite,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

// Get all favorites for one user
const getFavoritesByUser = async (req, res) => {
  try {
    const favorites = await Favorite.find({ userId: req.params.userId }).sort({
      createdAt: -1,
    });

    res.status(200).json({
      message: "Favorites fetched successfully",
      favorites,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

// Delete favorite by ID
const deleteFavorite = async (req, res) => {
  try {
    const deletedFavorite = await Favorite.findByIdAndDelete(req.params.id);

    if (!deletedFavorite) {
      return res.status(404).json({
        message: "Favorite not found",
      });
    }

    res.status(200).json({
      message: "Favorite deleted successfully",
      favorite: deletedFavorite,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

module.exports = {
  addFavorite,
  getFavoritesByUser,
  deleteFavorite,
};