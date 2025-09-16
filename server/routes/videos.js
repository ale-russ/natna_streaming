const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");
const { body, query, param, validationResult } = require("express-validator");

const { google } = require("googleapis");
const { authMiddleware, fetchUser } = require("../middleware/authMiddleware");
console.log("authMiddleware type:", typeof authMiddleware);
console.log("fetchUser type:", typeof fetchUser);
require("dotenv").config();

const youtube = google.youtube({
  version: "v3",
  auth: process.env.YOUTUBE_API_KEY,
});

//test-api
router.get("/test-api", async (req, res) => {
  try {
    const response = await youtube.search.list({
      part: "snippet",
      channelId: "UCBR8-60-B28hp2BmDPdntcQ",
      maxResults: 5,
      type: "video",
      fields: "items(id/videoId,snippet/title,snippet/thumbnails/default/url)",
    });
    res.json({ message: "Success", videos: response.data.items });
  } catch (err) {
    console.log("Error: ", err);
    res.status(500).json({
      error: "API test failed",
      status: err.status,
      details: err.message,
    });
  }
});

//search channels
router.get(
  "/search/:userId",
  [
    param("userId").isMongoId().withMessage("Invalid userId"),
    query("query").optional().trim(),
    // query("query").notEmpty().withMessage("Search query is required"),
    query("type")
      .isIn(["channel", "video"])
      .withMessage("Type must be channel or video"),
    // query("maxResults")
    //   .isInt({ min: 1, max: 200 })
    //   .withMessage("maxResults must be between 1 and 50"),
    query("pageToken").optional().trim(),
    authMiddleware,
    fetchUser,
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res
        .status(400)
        .json({ error: "Validation failed", details: errors.array() });

    try {
      let {
        query = "",
        type = "channel",
        maxResults = 20,
        pageToken,
      } = req.query;
      searchQuery = "children songs " + (query || "");
      const { blacklist } = req.user;
      const response = await youtube.search.list({
        part: "snippet",
        q: searchQuery,
        safeSearch: "strict", // Enforce family-friendly results
        type,
        maxResults,
        pageToken,
        fields:
          type === "channel"
            ? "items(id/channelId, snippet/title, snippet/description, snippet/thumbnails/default/url, snippet/channelId), nextPageToken"
            : "items(id/videoId, snippet/title,snippet/description, snippet/thumbnails/default/url, snippet/channelId), nextPageToken",
      });

      // Filter out blacklisted items
      const results = (response.data.items || [])
        .filter((item) => {
          const itemId =
            type === "channelId" ? item.id.channelId : item.id.videoId;
          const itemChannel = item.snippet.channelId;
          // For channels: filter if channelId is blacklisted
          // For videos: filter if videoId in blacklist OR channelId in blacklist
          return (
            !blacklist.includes(itemId) && !blacklist.includes(itemChannel)
          );
        })
        .map((item) => ({
          id: type === "channel" ? item.id.channelId : item.id.videoId,
          title: item.snippet.title,
          description: item.snippet.description,
          thumbnail: item.snippet.thumbnails.default.url,
          channelId: item.snippet.channelId,
        }));

      res.json({
        message: "Search results",
        results,
        nextPageToken: response.data.nextPageToken,
      });
    } catch (err) {
      console.error("Search Error: ", JSON.stringify(err, null, 2));
      if (err.code === 403 && err.errors?.[0].reason === "quoteExceeded") {
        res
          .status(429)
          .json({ error: "YouTube API quota exceeded", details: err.message });
      } else {
        res
          .status(500)
          .json({ error: "Failed to search ", details: err.message });
      }
    }
  }
);

//Add to whitelist
router.post(
  "/whitelist/:userId",
  [
    param("userId").isMongoId().withMessage("Invalid userId"),
    authMiddleware,
    fetchUser,
    body("itemId").notEmpty().withMessage("itemId is required"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res
        .status(400)
        .json({ error: "Validation failed", details: errors.array() });
    try {
      const { itemId } = req.body;
      const user = req.user;

      if (!user.whitelist.includes(itemId)) {
        user.whitelist.push(itemId);
        await user.save();
        console.log(
          `Added ${itemId} to whitelist for user ${req.params.userId}`
        );
      }

      res.json({ message: `Added ${itemId} to whitelist` });
    } catch (err) {
      console.error("Whitelist Error: ", JSON.stringify(err, null, 2));
      res
        .status(500)
        .json({ error: "Failed to add to whitelist ", details: err.message });
    }
  }
);

// Fetch curated videos
router.get(
  "/curated/:userId",
  [
    param("userId").isMongoId().withMessage("Invalid userId"),
    authMiddleware,
    fetchUser,
  ],
  async (req, res) => {
    try {
      const { whitelist, blacklist, parentalKeywords } = req.user;
      const newBlacklistItems = []; // Collect items to blacklist
      const filteredVideos = [];

      for (const channelId of whitelist) {
        if (blacklist.includes(channelId)) {
          console.log(`Skipping blacklisted channel: ${channelId}`);
          continue;
        }

        let response;
        try {
          response = await youtube.search.list({
            part: "snippet",
            channelId,
            maxResults: 10,
            type: "video",
            fields:
              "items(id/kind,id/videoId,snippet/title,snippet/description,snippet/thumbnails/default/url)",
            order: "date",
          });
        } catch (apiError) {
          console.error(
            `API error for channel ${channelId}:`,
            apiError.message
          );
          continue;
        }

        if (!response.data.items || response.data.items.length === 0) {
          console.log(`No items returned for channel: ${channelId}`);
          continue;
        }

        for (const item of response.data.items) {
          if (
            !item.id ||
            item.id.kind !== "youtube#video" ||
            !item.id.videoId
          ) {
            console.log(
              `Skipping invalid item: ${JSON.stringify(item, null, 2)}`
            );
            continue;
          }

          const videoId = item.id.videoId;
          if (blacklist.includes(videoId)) {
            console.log(`Skipping blacklisted video: ${videoId}`);
            continue;
          }

          const title = item.snippet.title.toLowerCase();
          const description = item.snippet.description?.toLowerCase() || "";
          if (
            parentalKeywords.some(
              (kw) =>
                title.includes(kw.toLowerCase()) ||
                description.includes(kw.toLowerCase())
            )
          ) {
            console.log(
              `Auto-blacklisting video: ${videoId} due to keyword match`
            );
            newBlacklistItems.push(videoId);
            continue;
          }

          filteredVideos.push({
            videoId,
            title: item.snippet.title,
            description: item.snippet.description,
            thumbnail: item.snippet.thumbnails?.default?.url || "",
            channelId: item.snippet.channelId,
          });
        }
      }

      // Bulk update blacklist
      if (newBlacklistItems.length > 0) {
        req.user.blacklist.push(
          ...newBlacklistItems.filter(
            (item) => !req.user.blacklist.includes(item)
          )
        );
        await req.user.save();
        console.log(
          `Updated blacklist with ${newBlacklistItems.length} new items`
        );
      }

      res.json({ message: "Success", videos: filteredVideos });
    } catch (error) {
      console.error("Curated Videos Error:", JSON.stringify(error, null, 2));
      if (error.code === 403 && error.errors?.[0]?.reason === "quotaExceeded") {
        res.status(429).json({
          error: "YouTube API quota exceeded",
          details: error.message,
        });
      } else {
        res.status(500).json({
          error: "Failed to fetch curated videos",
          details: error.message,
        });
      }
    }
  }
);

// Block video or channel
router.post(
  "/block/:userId",
  [
    param("userId").isMongoId().withMessage("Invalid userId"),
    authMiddleware,
    fetchUser,
    body("itemId").notEmpty().withMessage("itemId is required"),
    body("isChannel").isBoolean().withMessage("isChannel must be a boolean"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res
        .status(400)
        .json({ error: "Validation failed", details: errors.array() });

    try {
      const { itemId, isChannel } = req.body;
      const user = req.user;

      if (!user.blacklist.includes(itemId)) {
        user.blacklist.push(itemId);
        await user.save();
        console.log(
          `Blocked ${isChannel ? "channel" : "video"} ${itemId} for user ${
            req.params.userId
          }`
        );
      } else {
        return res.json({ message: "Item already blocked" });
      }

      // In a real app, you'd refresh the client's list: here, just confirm
      res.status(200).json({
        message: `Blocked ${isChannel ? "channel" : "video"} ${itemId}`,
      });
    } catch (err) {
      console.log(`err: ${err}`);
      res.status(500).json({ error: "Failed to block item" });
    }
  }
);

// Remove from blacklist
router.delete(
  "/unblock/:userId",
  [
    param("userId").isMongoId().withMessage("Invalid userId"),
    body("itemId").notEmpty().withMessage("itemId is required"),
    authMiddleware,
    fetchUser,
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res
        .status(400)
        .json({ error: "Validation failed", details: errors.array() });

    try {
      const { itemId } = req.body;
      const user = req.user;

      if (!user.blacklist.includes(itemId)) {
        return res
          .status(400)
          .json({ error: `Item ${itemId} not in blacklist` });
      }

      user.blacklist = user.blacklist.filter((id) => id !== itemId);
      await user.save();

      res.status(200).json({ message: `Removed ${itemId} from blacklist` });
    } catch (err) {
      console.log("Error: ", err);
      res.status(500).json({ error: "Failed to remove item from blacklist" });
    }
  }
);

// fetch blocked items
router.get(
  "/blacklist/:userId",
  [
    param("userId").isMongoId().withMessage("Invalid userId"),
    authMiddleware,
    fetchUser,
  ],
  async (req, res) => {
    const errors = validationResult(req);

    if (!errors.isEmpty()) {
      return res
        .status(400)
        .json({ error: "Validation failed", details: errors.array() });
    }

    console.log("userId in blacklist fetching: ", req.user.id);

    try {
      const { blacklist } = req.user;
      if (!blacklist || blacklist.length === 0) {
        return res.json({ message: "No blocked items", results: [] });
      }

      console.log("blacklist: ", blacklist);

      //separate channel ids and video ids
      const videoIds = blacklist.filter((id) => !id.startsWith("UC"));
      const channelIds = blacklist.filter((id) => id.startsWith("UC"));

      const results = [];

      //  fetch video details
      if (videoIds.length > 0) {
        const videoResponse = await youtube.videos.list({
          part: "snippet",
          id: videoIds.join(","),
          fields:
            "items(id, snippet/title, snippet/thumbnails/default/url, snippet/channelId)",
        });

        results.push(
          ...(videoResponse.data.items || []).map((item) => ({
            id: item.id,
            title: item.snippet.title,
            thumbnail: item.snippet.thumbnails.default.url,
            channelId: item.snippet.channelId,
          }))
        );
      }

      // Fetch channel details
      if (channelIds.length > 0) {
        const channelResponse = await youtube.channels.list({
          part: "snippet",
          id: channelIds.join(","),
          fields:
            "items(id, snippet/title, snippet/description, snippet/thumbnails/default/url)",
        });

        results.push(
          ...(channelResponse.data.items || []).map((item) => ({
            id: item.id,
            title: item.snippet.title,
            description: item.snippet.description,
            thumbnail: item.snippet.thumbnails.default.url,
            channelId: item.id,
          }))
        );
      }

      res.status(200).json({ message: "Blacklist items", results: results });
    } catch (err) {
      console.log("Error: ", err);
      res.status(500).json({ error: "Failed to fetch blocked items" });
    }
  }
);

//Report channel or video
router.post(
  "/report/:userId",
  [
    param("userId").isMongoId().withMessage("Invalid userId"),
    authMiddleware,
    fetchUser,
    body("itemId").notEmpty().withMessage("itemId is required"),
    body("isChannel").isBoolean().withMessage("isChannel must be a boolean"),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res
        .status(400)
        .json({ error: "Validation failed", details: errors.array() });

    try {
      const { itemId, isChannel } = req.body;
      const user = req.user;

      // For now, just log the report; in production, save to a report collection or notify admins
      console.log(
        `Reported ${isChannel ? "channel" : "video"} ${itemId} by user ${
          req.params.userId
        }`
      );
      // Optionally, add to user.reported if you add the field to the model
      // if (!user.reported?.includes(itemId)) {
      //   user.reported = user.reported || [];
      //   user.reported.push(itemId);
      //   await user.save();
      // }

      res.json({
        message: `Reported ${isChannel ? "channel" : "video"} ${itemId}`,
      });
    } catch (err) {
      console.error("Report Error: ", JSON.stringify(err, null, 2));
      res
        .status(500)
        .json({ error: "Failed to report item", details: err.message });
    }
  }
);

module.exports = router;
