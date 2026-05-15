const express = require("express");
const router = express.Router();
const { herbChat } = require("../controllers/aiChatController");

router.post("/", herbChat);

module.exports = router;