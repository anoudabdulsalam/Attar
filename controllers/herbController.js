const Herb = require("../models/Herb");

// Add new herb
const addHerb = async (req, res) => {
  try {
    const {
      name,
      scientificName,
      description,
      benefits,
      usageMethod,
      season,
      category,
      imageUrl,
      price,
      quantity,
      storeOwnerId,
      storeName,
      onSale,
      salePrice,
    } = req.body;

    if (!name) {
      return res.status(400).json({
        message: "Herb name is required",
      });
    }

    const newHerb = new Herb({
      name,
      scientificName,
      description,
      benefits,
      usageMethod,
      season,
      category,
      imageUrl,
      price,
      quantity,
      storeOwnerId,
      storeName,
      onSale,
      salePrice,
    });

    await newHerb.save();

    res.status(201).json({
      message: "Herb added successfully",
      herb: newHerb,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

// Get all herbs
const getAllHerbs = async (req, res) => {
  try {
    const herbs = await Herb.find().sort({ createdAt: -1 });

    res.status(200).json({
      message: "Herbs fetched successfully",
      herbs,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

// Get herb by ID
const getHerbById = async (req, res) => {
  try {
    const herb = await Herb.findById(req.params.id);

    if (!herb) {
      return res.status(404).json({
        message: "Herb not found",
      });
    }

    res.status(200).json({
      message: "Herb fetched successfully",
      herb,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

// Update herb by ID
const updateHerb = async (req, res) => {
  try {
    const updatedHerb = await Herb.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    if (!updatedHerb) {
      return res.status(404).json({
        message: "Herb not found",
      });
    }

    res.status(200).json({
      message: "Herb updated successfully",
      herb: updatedHerb,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

// Delete herb by ID
const deleteHerb = async (req, res) => {
  try {
    const deletedHerb = await Herb.findByIdAndDelete(req.params.id);

    if (!deletedHerb) {
      return res.status(404).json({
        message: "Herb not found",
      });
    }

    res.status(200).json({
      message: "Herb deleted successfully",
      herb: deletedHerb,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const addCommentToHerb = async (req, res) => {
  try {
    const { userId, userName, userRole, text } = req.body;

    if (!text) {
      return res.status(400).json({
        message: "Comment text is required",
      });
    }

    const herb = await Herb.findById(req.params.id);

    if (!herb) {
      return res.status(404).json({
        message: "Herb not found",
      });
    }

    herb.comments.unshift({
      userId,
      userName,
      userRole,
      text,
    });

    await herb.save();

    res.status(200).json({
      message: "Comment added successfully",
      herb,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};
module.exports = {
  addHerb,
  getAllHerbs,
  getHerbById,
  updateHerb,
  deleteHerb,
  addCommentToHerb,
};