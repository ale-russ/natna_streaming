const jwt = require("jsonwebtoken");
const User = require("../models/User");

// Authentication middleware
const authMiddleware = async (req, res, next) => {
  try {
    // Get token from Authorization header {Bearer <token>}
    const token = req.header("Authorization")?.replace("Bearer ", "");
    if (!token) return res.status(401).json({ message: "No Token Provided" });

    // verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded.userId; //Attach user info to request
    next();
  } catch (err) {
    res.status(401).json({ message: "Invalid or expired token" });
  }
};

// Middleware to fetch user
const fetchUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.userId).select("-password");
    if (!user)
      return res
        .status(400)
        .json({ error: "User not found", userId: req.params.userId });

    req.user = user;
    next();
  } catch (err) {
    console.error("Fetch User Error", JSON.stringify(err, null, 2));
    res
      .status(500)
      .json({ error: "Failed to fetch user!", details: err.message });
  }
};

module.exports = { authMiddleware, fetchUser };
