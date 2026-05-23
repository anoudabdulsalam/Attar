const Herb = require("../models/Herb");
const Order = require("../models/Order");

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
      saleUpdatedAt: onSale ? new Date() : null,
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

    const herbsWithAverage = herbs.map((herb) => {
      const ratingsCount = herb.ratings.length;

      const averageRating =
        ratingsCount === 0
          ? 0
          : herb.ratings.reduce((sum, r) => sum + r.rating, 0) /
            ratingsCount;

      return {
        ...herb.toObject(),
        averageRating,
        ratingsCount,
      };
    });

    res.status(200).json({
      message: "Herbs fetched successfully",
      herbs: herbsWithAverage,
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

    const ratingsCount = herb.ratings.length;

    const averageRating =
      ratingsCount === 0
        ? 0
        : herb.ratings.reduce((sum, r) => sum + r.rating, 0) /
          ratingsCount;

    res.status(200).json({
      message: "Herb fetched successfully",
      herb: {
        ...herb.toObject(),
        averageRating,
        ratingsCount,
      },
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
    const updateData = { ...req.body };

    if (updateData.onSale === true) {
      updateData.saleUpdatedAt = new Date();
    }

    const updatedHerb = await Herb.findByIdAndUpdate(
      req.params.id,
      updateData,
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

const rateHerb = async (req, res) => {
  try {
    const { userId, rating } = req.body;

    const herbId = req.params.id;

    if (!userId || !rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        message: "Valid userId and rating (1-5) are required",
      });
    }

    // لازم يكون مشتري ومستلم
    const completedOrder = await Order.findOne({
      buyerId: userId,
      status: "تم الاستلام",
      "items.herbId": herbId,
    });

    if (!completedOrder) {
      return res.status(403).json({
        message: "لا يمكنك تقييم هذه العشبة إلا بعد شرائها واستلامها",
      });
    }

    const herb = await Herb.findById(herbId);

    if (!herb) {
      return res.status(404).json({
        message: "Herb not found",
      });
    }

    const existingRatingIndex = herb.ratings.findIndex(
      (r) => r.userId === userId
    );

    // إذا قيّم قبل يعدل تقييمه
    if (existingRatingIndex !== -1) {
      herb.ratings[existingRatingIndex].rating = rating;
    } else {
      herb.ratings.push({
        userId,
        rating,
      });
    }

    const ratingsCount = herb.ratings.length;

    const averageRating =
      ratingsCount === 0
        ? 1
        : herb.ratings.reduce((sum, r) => sum + r.rating, 0) /
          ratingsCount;

    herb.averageRating = averageRating;

    await herb.save();

    res.status(200).json({
      message: "Herb rated successfully",
      averageRating,
      ratingsCount,
      herb,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const likeComment = async (req, res) => {
  try {
    const { userId } = req.body;
    const { id, commentId } = req.params;

    if (!userId) {
      return res.status(400).json({
        message: "User ID is required",
      });
    }

    const herb = await Herb.findById(id);

    if (!herb) {
      return res.status(404).json({
        message: "Herb not found",
      });
    }

    const comment = herb.comments.id(commentId);

    if (!comment) {
      return res.status(404).json({
        message: "Comment not found",
      });
    }

    const likeIndex = comment.likes.indexOf(userId);

    if (likeIndex > -1) {
      comment.likes.splice(likeIndex, 1);
    } else {
      comment.likes.push(userId);
    }

    await herb.save();

    res.status(200).json({
      message: "Comment like toggled successfully",
      herb,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const replyToComment = async (req, res) => {
  try {
    const { userId, userName, userRole, text } = req.body;
    const { id, commentId } = req.params;

    if (!userId || !userName || !userRole || !text) {
      return res.status(400).json({
        message: "All fields are required",
      });
    }

    const herb = await Herb.findById(id);

    if (!herb) {
      return res.status(404).json({
        message: "Herb not found",
      });
    }

    const comment = herb.comments.id(commentId);

    if (!comment) {
      return res.status(404).json({
        message: "Comment not found",
      });
    }

    comment.replies.push({
      userId,
      userName,
      userRole,
      text,
    });

    await herb.save();

    res.status(200).json({
      message: "Reply added successfully",
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
  rateHerb,
  likeComment,
  replyToComment,
};