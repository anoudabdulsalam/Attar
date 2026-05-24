const Order = require("../models/Order");
const Herb = require("../models/Herb");
const User = require("../models/User");

const createOrder = async (req, res) => {
  try {
    const { buyerId, buyerName, buyerRole, storeOwnerId, storeName, items, totalPrice } = req.body;

    if (!buyerId || !storeOwnerId || !items || items.length === 0) {
      return res.status(400).json({ message: "Missing order data" });
    }

    const user = await User.findById(buyerId);

    const normalizedItems = [];

    for (const item of items) {
      const herb = await Herb.findById(item.herbId);

      if (!herb) {
        return res.status(404).json({
          message: `Herb not found: ${item.herbName}`,
        });
      }

      if (herb.quantity < item.quantity) {
        return res.status(400).json({
          message: `الكمية غير كافية من ${herb.name}`,
        });
      }

      herb.quantity -= item.quantity;

      if (herb.salesCount === undefined) {
        herb.salesCount = 0;
      }

      herb.salesCount += item.quantity;

      await herb.save();

      normalizedItems.push({
        herbId: item.herbId,
        herbName: item.herbName || herb.name,
        imageUrl: item.imageUrl || herb.imageUrl || "",
        quantity: item.quantity,
        price: item.price || herb.price || 0,
        storeName: item.storeName || storeName || "متجر غير معروف",
      });

      if (user) {
        const prefIndex = user.herbPreferences.findIndex(
          (p) => p.herbId === item.herbId
        );

        if (prefIndex !== -1) {
          user.herbPreferences[prefIndex].score += 5;
        } else {
          user.herbPreferences.push({
            herbId: item.herbId,
            score: 5,
          });
        }
      }
    }

    if (user) {
      await user.save();
    }

    const order = await Order.create({
      buyerId,
      buyerName,
      buyerRole,
      storeOwnerId,
      storeName,
      items,
      totalPrice,
      status: "قيد التحضير",
    });

    res.status(201).json({
      message: "Order created successfully",
      order,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const getOrdersByBuyer = async (req, res) => {
  try {
    const orders = await Order.find({
      buyerId: req.params.buyerId,
    }).sort({ createdAt: -1 });

    res.status(200).json({ orders });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const getOrdersByStoreOwner = async (req, res) => {
  try {
    const orders = await Order.find({
      storeOwnerId: req.params.storeOwnerId,
    }).sort({ createdAt: -1 });

    res.status(200).json({ orders });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const getAllOrdersByStoreOwner = async (req, res) => {
  try {
    const orders = await Order.find({
      storeOwnerId: req.params.storeOwnerId,
    }).sort({ createdAt: -1 });

    res.status(200).json({ orders });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;

    const updateData = { status };

    if (status === "تم الاستلام") {
      updateData.receivedAt = new Date();
    }

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    res.status(200).json({
      message: "Order updated",
      order,
    });
  } catch (error) {
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

module.exports = {
  createOrder,
  getOrdersByBuyer,
  getOrdersByStoreOwner,
  updateOrderStatus,
  getAllOrdersByStoreOwner,
};