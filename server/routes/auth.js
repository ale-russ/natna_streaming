const express = require("express");
const { body, param, validationResult } = require("express-validator");
const bcrypt = require("bcrypt");
const passport = require("passport");
const GoogleStrategy = require("passport-google-oauth20").Strategy;
const jwt = require("jsonwebtoken");
require("dotenv").config();

const User = require("../models/User");
const { authMiddleware } = require("../middleware/authMiddleware");

const router = express.Router();

//Initialize Google OAuth
passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "http://localhost:3000/auth/google/callback", //update on production,
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        let user = await User.findOne({ googleId: profile.id });
        if (!user) {
          user = new User({
            googleId: profile.id,
            email: profile.emails[0].value,
            fullName: profile.displayName,
            ageRange: "2-8", //Default for new users
          });
          await user.save();
        }
        return done(null, user);
      } catch (err) {
        return done(null, profile);
      }
    }
  )
);

//Serialize/deserialize user for passport
passport.serializeUser((user, done) => done(null, user._id));
passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (err) {
    done(err, null);
  }
});

// Google OAuth login
router.get(
  "/google",
  passport.authenticate("google", { scope: ["profile", "email"] })
);

//Google OAuth callback
router.get(
  "/google/callback",
  passport.authenticate("google", {
    session: false,
    failureRedirect: "/login",
  }),
  (req, res) => {
    try {
      const token = jwt.sign(
        { userId: req.res.user._id },
        process.env.JWT_SECRET,
        { expiresIn: "90d" }
      );
      res.redirect(`myapp://auth?token=${token}`);
    } catch (error) {
      console.error("Google Callback Error:", JSON.stringify(error, null, 2));
      res.status(500).json({
        error: "Failed to process Google login",
        details: error.message,
      });
    }
  }
);

// Register route
router.post(
  "/signup",
  [
    body("fullName").notEmpty().trim().escape().withMessage("Name is required"),
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Invalid email format"),
    // body("password")
    //   .isLength({ min: 8 })
    //   .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/)
    //   .withMessage(
    //     "Password must include uppercase, lowercase, number, special char"
    //   ),
    body("ageRange")
      .optional()
      .isIn(["2-4", "5-8", "9-12"])
      .withMessage("Invalid age range"),
    body("parentalPin")
      .optional()
      .isLength({ min: 4, max: 4 })
      .withMessage("PIN must be 4 digits"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res
        .status(400)
        .json({ error: "Validation failed", details: errors.array() });
    try {
      const { fullName, email, password, ageRange, parentalPin } = req.body;
      console.log("body: ", req.body);
      // Check if user already exists
      const existingUser = await User.findOne({ email });

      console.log("existingUser: ", existingUser);

      if (existingUser)
        return res.status(400).json({ error: "User Already Registered" });

      // Hash password;
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
      const hashedPin = parentalPin
        ? await bcrypt.hash(parentalPin, salt)
        : undefined;

      // Create new user
      const user = new User({
        fullName,
        email,
        password: hashedPassword,
        parentalPin: hashedPin,
        ageRange: ageRange || "2-8",
      });
      await user.save();

      // Generate JWT token
      const token = jwt.sign(
        { userId: user._id, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: "90d" }
      );

      res.status(201).json({
        message: "User registered successfully",
        token,
        user: user.toSafeObject(),
      });
    } catch (err) {
      console.error("Signup Error:", JSON.stringify(err, null, 2));
      res
        .status(500)
        .json({ error: "Failed to register user", details: error.message });
    }
  }
);

// Login route
router.post(
  "/login",
  [
    body("email")
      .isEmail()
      .normalizeEmail()
      .withMessage("Invalid email format"),
    body("password").notEmpty().withMessage("Password is required"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res
        .status(400)
        .json({ error: "Validation failed", details: errors.array() });
    try {
      const { email, password } = req.body;

      // Find user
      const user = await User.findOne({ email });
      console.log("User: ", user);

      if (!user)
        return res.status(400).json({ error: "Invalid email or password" });

      // Verify password
      const isMatch = await bcrypt.compare(password, user.password);
      console.log("isMatch: ", isMatch);
      if (!isMatch)
        return res.status(400).json({ error: "Invalid email or password" });

      // Generate JWT token
      const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
        expiresIn: "90d",
      });

      res.status(200).json({
        message: "Login successful",
        token,
        user: user.toSafeObject(),
      });
    } catch (err) {
      console.error("Login Error:", JSON.stringify(error, null, 2));
      res.status(500).json({ error: "Failed to login", details: err.message });
    }
  }
);

//Verify parental PIN
router.post(
  "/verify-pin/:userId",
  [
    param("userId").isMongoId().withMessage("Invalid userId"),
    body("pin")
      .isLength({ min: 4, max: 4 })
      .withMessage("PIN must be at least 4 digits"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res
        .status(400)
        .json({ error: "Validation failed", details: errors.array() });
    try {
      const { userId } = req.params;
      const { pin } = req.body;
      const user = await User.findById(userId);

      if (!user) return res.status(404).json({ error: "User not found" });

      if (!user.parentalPin)
        return res.status(400).json({ error: "No PIN set for this user" });

      const isMatch = await bcrypt.compare(pin, user.parentalPin);
      if (!isMatch) return res.status(400).json({ error: "Invalid PIN" });

      res.json({ message: "PIN verified successfully" });
    } catch (err) {
      console.error("PIN Verification Error: ", JSON.stringify(error, null, 2));
      res
        .status(500)
        .json({ error: "Failed to verify PIN", details: error.message });
    }
  }
);

//refresh-token
router.post("/refresh-token", authMiddleware, async (req, res) => {
  const token = jwt.sign({ userId: req.userId }, process.env.JWT_SECRET, {
    expiresIn: "90d",
  });
  res.json({ message: "Token refreshed: ", token });
});

module.exports = router;
