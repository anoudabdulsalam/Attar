const Order = require("../models/Order");
const Herb = require("../models/Herb");
const User = require("../models/User");

const createOrder = async (req, res) => {
  try {
    const {
      buyerId,
      buyerName,
      buyerRole,
      storeOwnerId,
      storeName,
      items,
      totalPrice,
    } = req.body;

    if (!buyerId || !storeOwnerId || !items || items.length === 0) {
      return res.status(400).json({
        message: "Missing order data",
      });
    }

    const user = await User.findById(buyerId);

    if (user && !Array.isArray(user.herbPreferences)) {
      user.herbPreferences = [];
    }

    const normalizedItems = [];

    for (const item of items) {
      const herbId = item.herbId || item.id;

      if (!herbId) {
        return res.status(400).json({
          message: `Missing herbId for item: ${item.herbName || item.name || ""}`,
        });
      }

      const herb = await Herb.findById(herbId);

      if (!herb) {
        return res.status(404).json({
          message: `Herb not found: ${item.herbName || item.name || herbId}`,
        });
      }

      const requestedQty = Number(item.quantity || 1);

      if (Number(herb.quantity || 0) < requestedQty) {
        return res.status(400).json({
          message: `الكمية غير كافية من ${herb.name}`,
        });
      }

      herb.quantity = Number(herb.quantity || 0) - requestedQty;
      herb.salesCount = Number(herb.salesCount || 0) + requestedQty;

      await herb.save();

      normalizedItems.push({
        herbId: herbId,
        herbName: item.herbName || item.name || herb.name,
        imageUrl: item.imageUrl || herb.imageUrl || "",
        quantity: requestedQty,
        price: Number(item.price || herb.price || 0),
        storeName: item.storeName || storeName || "متجر غير معروف",
      });

      if (user) {
        const prefIndex = user.herbPreferences.findIndex(
          (p) => p.herbId && p.herbId.toString() === herbId.toString()
        );

        if (prefIndex !== -1) {
          user.herbPreferences[prefIndex].score =
            Number(user.herbPreferences[prefIndex].score || 0) + 5;
        } else {
          user.herbPreferences.push({
            herbId: herbId,
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
      buyerName: buyerName || "زبون",
      buyerRole: buyerRole || "customer",
      storeOwnerId,
      storeName: storeName || "متجر غير معروف",
      items: normalizedItems,
      totalPrice: Number(totalPrice || 0),
      status: "قيد التحضير",
    });

    res.status(201).json({
      message: "Order created successfully",
      order,
    });
  } catch (error) {
    console.log("CREATE ORDER ERROR:", error);

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

    const order = await Order.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
    });

    if (!order) {
      return res.status(404).json({
        message: "Order not found",
      });
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