const express = require("express");
const { google } = require("googleapis");
const { connectDB } = require("./config/db");

const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/user_routes");
const youtubeRoutes = require("./routes/videos");

require("dotenv").config();

const app = express();
const port = process.env.PORT || 3000;

const startServer = async () => {
  await connectDB();

  //   YouTube API Client
  const youtube = google.youtube({
    version: "v3",
    auth: process.env.YOUTUBE_API_KEY,
  });

  // Middleware
  app.use(express.json());
  // Routes
  app.get("/", (req, res) => res.send("Backend API running"));

  app.use("/auth", authRoutes);
  app.use("/api", userRoutes);
  app.use("/api/youtube", youtubeRoutes);

  //global error handler
  app.use((err, req, res, next) => {
    console.error("Global Error:", JSON.stringify(err, null, 2));
    res
      .status(500)
      .json({ error: "Internal server error", details: err.message });
  });

  // Start server
  app.listen(port, () => console.log(`Server running on port ${port}`));
};

startServer();
