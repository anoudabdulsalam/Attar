const express = require("express");
const router = express.Router();
const {
  addHerb,
  getAllHerbs,
  getHerbById,
  updateHerb,
  deleteHerb,
  addCommentToHerb,
} = require("../controllers/herbController");

router.post("/", addHerb);
router.get("/", getAllHerbs);
router.get("/:id", getHerbById);
router.put("/:id", updateHerb);
router.delete("/:id", deleteHerb);
router.post("/:id/comments", addCommentToHerb);
module.exports = router;