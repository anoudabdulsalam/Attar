const express = require("express");
const router = express.Router();

const Herb = require("../models/Herb");

const {
  addHerb,
  getAllHerbs,
  getHerbById,
  updateHerb,
  deleteHerb,
  addCommentToHerb,
  rateHerb,
} = require("../controllers/herbController");

router.post("/", addHerb);
router.get("/", getAllHerbs);

router.get("/owner/:ownerId", async (req, res) => {
  try {
    const ownerId = req.params.ownerId;

    const herbs = await Herb.find({
      storeOwnerId: ownerId,
    }).sort({ createdAt: -1 });

    res.status(200).json({
      herbs: herbs,
    });
  } catch (error) {
    res.status(500).json({
      message: "فشل جلب أعشاب صاحب المتجر",
      error: error.message,
    });
  }
});

router.get("/:id", getHerbById);
router.put("/:id", updateHerb);
router.delete("/:id", deleteHerb);
router.post("/:id/comments", addCommentToHerb);
router.post("/:id/rate", rateHerb);

module.exports = router;