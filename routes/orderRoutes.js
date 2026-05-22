const express = require("express");
const router = express.Router();

const {
  createOrder,
  getOrdersByBuyer,
  getOrdersByStoreOwner,
  updateOrderStatus,
  getAllOrdersByStoreOwner,
} = require("../controllers/orderController");

router.post("/", createOrder);
router.get("/buyer/:buyerId", getOrdersByBuyer);
router.get("/store/:storeOwnerId/all", getAllOrdersByStoreOwner);
router.get("/store/:storeOwnerId", getOrdersByStoreOwner);
router.put("/:id/status", updateOrderStatus);

module.exports = router;