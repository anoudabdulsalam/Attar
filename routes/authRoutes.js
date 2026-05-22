const User = require("../models/User");
const express = require("express");
const router = express.Router();
const { registerUser, loginUser } = require("../controllers/authController");
const nodemailer = require("nodemailer");
const bcrypt = require("bcryptjs");

const resetCodes = new Map();
// Nodemailer transporter configuration
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

router.post("/register", registerUser);
router.post("/login", loginUser);

router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({
        message: "البريد الإلكتروني غير موجود",
      });
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString();

    resetCodes.set(email, {
      code,
      expiresAt: Date.now() + 5 * 60 * 1000,
    });

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: "رمز إعادة تعيين كلمة المرور",
      html: `
        <h2>رمز التحقق الخاص بك:</h2>
        <h1>${code}</h1>
        <p>ينتهي خلال 5 دقائق</p>
      `,
    });

    res.json({
      success: true,
      message: "تم إرسال رمز التحقق",
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

router.post("/verify-reset-code", async (req, res) => {
  try {
    const { email, code } = req.body;

    const savedCode = resetCodes.get(email);

    if (!savedCode) {
      return res.status(400).json({
        success: false,
        message: "لا يوجد رمز لهذا البريد",
      });
    }

    if (Date.now() > savedCode.expiresAt) {
      return res.status(400).json({
        success: false,
        message: "انتهت صلاحية الرمز",
      });
    }

    if (savedCode.code !== code) {
      return res.status(400).json({
        success: false,
        message: "الرمز غير صحيح",
      });
    }

    res.json({
      success: true,
      message: "تم التحقق بنجاح",
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

router.post("/reset-password", async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;

    const savedCode = resetCodes.get(email);

    if (!savedCode) {
      return res.status(400).json({
        success: false,
        message: "الرمز غير موجود",
      });
    }

    if (savedCode.code != code) {
      return res.status(400).json({
        success: false,
        message: "رمز خاطئ",
      });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await User.findOneAndUpdate(
      { email },
      { password: hashedPassword }
    );

    resetCodes.delete(email);

    res.json({
      success: true,
      message: "تم تغيير كلمة المرور",
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

module.exports = router;