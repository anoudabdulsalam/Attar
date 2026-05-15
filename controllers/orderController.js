const Order = require('../models/orderModel');

const createOrder = async (req, res) => {
  try {
    const { customerName, items, totalPrice, paymentMethod, deliveryLocation, status } = req.body;

    if (!deliveryLocation || deliveryLocation.lat == null || deliveryLocation.lng == null) {
      return res.status(400).json({ message: 'Delivery location is required' });
    }

    if (!totalPrice || !paymentMethod) {
      return res.status(400).json({ message: 'totalPrice and paymentMethod are required' });
    }

    const order = await Order.create({
      customerName: customerName || 'Customer',
      items: items || [],
      totalPrice,
      paymentMethod,
      deliveryLocation,
      status: status || 'pending',
    });

    return res.status(201).json({
      message: 'Order created successfully',
      order,
    });
  } catch (error) {
    return res.status(500).json({
      message: 'Failed to create order',
      error: error.message,
    });
  }
};

module.exports = {
  createOrder,
};