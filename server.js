const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
require("dotenv").config();

const app = express();

connectDB();

app.use(cors());
app.use(express.json());
app.use("/api/accounting", require("./routes/accountingRoutes"));
app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/admin", require("./routes/adminRoutes"));
app.use("/api/ai/herb-chat", require("./routes/aiChatRoutes"));
app.use("/api/contact", require("./routes/contactRoutes"));
app.use("/api/herbs", require("./routes/herbRoutes"));
app.use("/api/favorites", require("./routes/favoriteRoutes"));
app.use("/api/users", require("./routes/userRoutes"));
app.use("/api/notifications", require("./routes/notificationRoutes"));
app.use("/api/orders", require("./routes/orderRoutes"));
app.use("/api/accounting", require("./routes/accountingRoutes"));
const chatRoutes = require("./routes/chatRoutes");
app.use("/api/chat", chatRoutes);
app.get("/", (req, res) => {
  res.json({ message: "Attar backend is running" });
});
const notificationRoutes = require("./routes/notificationRoutes");
app.use("/api/notifications", notificationRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});