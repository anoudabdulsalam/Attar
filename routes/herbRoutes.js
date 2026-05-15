const express = require("express");
const router = express.Router();
const {
  addHerb,
  getAllHerbs,
  getHerbById,
  updateHerb,
  deleteHerb,
} = require("../controllers/herbController");

router.post("/", addHerb);
router.get("/", getAllHerbs);
router.get("/:id", getHerbById);
router.put("/:id", updateHerb);
router.delete("/:id", deleteHerb);

module.exports = router;