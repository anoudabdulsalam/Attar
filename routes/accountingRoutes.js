const express = require("express");
const router = express.Router();

const {
  getAccountingByStoreOwner,
} = require("../controllers/accountingController");

router.get("/store/:storeOwnerId", getAccountingByStoreOwner);

module.exports = router;