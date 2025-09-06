const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const userSchema = new mongoose.Schema({
  // _id: { type: mongoose.Types.ObjectId, required: true },
  email: { type: String, required: true, unique: true },
  fullName: { type: String, required: true },
  password: {
    type: String,
    required: true,
    minlength: 6,
  },
  googleId: { type: String, unique: true, sparse: true },
  ageRang: { type: [String], default: "2-8" },
  whitelist: {
    type: [String],
    default: [
      "UC0sMioKZ2r1ADXOWrJgtq-A", // PBS Kids
      "UCoookXUzPciGrEZEXmh4Jjg", // Sesame Street
      "UCue7ZHOgg2kTBWlsOv_xAYw", // Cocomelon
      "UC6L4Y6fv8qW1jV3Jgtq-A",
    ],
  }, //Array of Channels/Video Ids
  blacklist: [String],
  parentalKeywords: [String],
  oauth: {
    accessToken: String,
    refreshToken: String,
  }, //Optional auto-filter keywords
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

userSchema.methods.toSafeObject = function () {
  const user = this.toObject();
  delete user.password;
  return user;
};

module.exports = mongoose.model("User", userSchema);
