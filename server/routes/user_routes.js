const express = require("express");

const User = require("../models/User");

const router = express.Router();

// fetch all users
router.get("/users", async (req, res) => {
  try {
    const users = await User.find();
    console.log("users: ", users);
    res.status(200).json({ message: "Success", users: users });
  } catch (err) {
    console.error("Error: ", err);
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

module.exports = router;
