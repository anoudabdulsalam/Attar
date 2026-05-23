const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
require("dotenv").config();
const Admin = require("./models/Admin");

mongoose.connect(process.env.MONGO_URI || "mongodb://127.0.0.1:27017/attar_db");

const seedAdmin = async () => {
  try {
    const email = "admin@attar.com";
    const existingAdmin = await Admin.findOne({ email });

    if (existingAdmin) {
      console.log("Admin already exists!");
      process.exit();
    }

    const hashedPassword = await bcrypt.hash("123456", 10);

    const admin = new Admin({
      email,
      password: hashedPassword,
      role: "admin",
    });

    await admin.save();
    console.log("Admin seeded successfully! Email: admin@attar.com, Password: 123456");
    process.exit();
  } catch (error) {
    console.error("Error seeding admin:", error);
    process.exit(1);
  }
};

seedAdmin();
