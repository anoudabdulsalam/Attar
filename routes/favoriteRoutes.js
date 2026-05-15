const express = require("express");
const router = express.Router();
const {
  addFavorite,
  getFavoritesByUser,
  deleteFavorite,
} = require("../controllers/favoriteController");

router.post("/", addFavorite);
router.get("/:userId", getFavoritesByUser);
router.delete("/:id", deleteFavorite);

module.exports = router;