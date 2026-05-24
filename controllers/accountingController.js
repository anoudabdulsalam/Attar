const Order = require("../models/Order");

const getAccountingByStoreOwner = async (req, res) => {
  try {
    const { storeOwnerId } = req.params;

    const orders = await Order.find({ storeOwnerId }).sort({ createdAt: -1 });

    let totalSales = 0;
    let totalExpenses = 0;
    let records = [];

    orders.forEach((order) => {
      totalSales += order.totalPrice || 0;
      totalExpenses += order.expenses || 0;

      order.items.forEach((item) => {
        const itemTotal = (item.price || 0) * (item.quantity || 1);

        records.push({
          invoice: order.orderNumber || order._id.toString().slice(-6),
          date: order.createdAt,
          customer: order.buyerName || "زبون",
          product: item.herbName,
          qty: item.quantity,
          unitPrice: item.price,
          discount: order.discount || 0,
          total: itemTotal,
          expenses: order.expenses || 0,
          netProfit: itemTotal - (order.expenses || 0),
          paymentStatus: order.paymentStatus || "قيد الانتظار",
          paymentMethod: order.paymentMethod || "غير محدد",
          orderStatus: order.status,
        });
      });
    });

    res.status(200).json({
      summary: {
        totalSales,
        totalExpenses,
        netProfit: totalSales - totalExpenses,
        ordersCount: orders.length,
      },
      records,
    });
  } catch (error) {
    res.status(500).json({
      message: "Failed to fetch accounting data",
      error: error.message,
    });
  }
};

module.exports = { getAccountingByStoreOwner };