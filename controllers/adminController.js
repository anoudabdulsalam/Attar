const Admin = require("../models/Admin");
const User = require("../models/User");
const Order = require("../models/Order");
const Herb = require("../models/Herb");
const ContactMessage = require("../models/ContactMessage");
const bcrypt = require("bcryptjs");

const adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required" });
    }

    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    res.status(200).json({
      message: "Admin login successful",
      admin: {
        id: admin._id,
        email: admin.email,
        role: admin.role,
      },
    });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

const getAllUsers = async (req, res) => {
  try {
    const users = await User.find({}).sort({ createdAt: -1 });
    res.status(200).json({ users });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findByIdAndDelete(id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    // Optional: Delete user related data like herbs, orders, etc.
    res.status(200).json({ message: "User deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

const getStoreStats = async (req, res) => {
  try {
    // We need to calculate for each store owner:
    // 1. Total sales this month
    // 2. Number of herbs added (total or this month - we'll just get all their herbs)
    // 3. Name and quantity of each herb

    // Find all store owners
    const storeOwners = await User.find({ role: "store_owner" });
    
    // Get current month start date
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const stats = await Promise.all(
      storeOwners.map(async (owner) => {
        // Find orders for this store owner in the current month
        const monthlyOrders = await Order.find({
          storeOwnerId: owner._id.toString(),
          createdAt: { $gte: startOfMonth },
        });

        // Calculate total sales
        const totalSales = monthlyOrders.reduce((sum, order) => sum + order.totalPrice, 0);

        // Find herbs added by this store owner
        const herbs = await Herb.find({ storeOwnerId: owner._id.toString() });

        const herbsList = herbs.map(h => ({
          name: h.name,
          quantity: h.quantity,
        }));

        return {
          ownerId: owner._id,
          ownerName: owner.ownerName,
          storeName: owner.storeName,
          totalSalesThisMonth: totalSales,
          totalHerbsAdded: herbs.length,
          herbs: herbsList,
        };
      })
    );

    res.status(200).json({ stats });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

const getMessages = async (req, res) => {
  try {
    const messages = await ContactMessage.find({}).sort({ createdAt: -1 });
    res.status(200).json({ messages });
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

module.exports = {
  adminLogin,
  getAllUsers,
  deleteUser,
  getStoreStats,
  getMessages,
};
