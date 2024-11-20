const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");

const app = express();
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose
  .connect("mongodb://localhost:27017/iteam", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log("Connected to MongoDB - Database: iteam");
  })
  .catch((err) => {
    console.error("Failed to connect to MongoDB", err);
  });

// Define MongoDB schemas and models
const postSchema = new mongoose.Schema({
  title: String,
  content: String,
  upvotes: Number,
  downvotes: Number,
  commentsCount: Number,
});

const communitySchema = new mongoose.Schema(
  {
    name: String,
    posts: [postSchema],
  },
  { collection: "communityDB" } // Explicitly set the collection name
);

const Community = mongoose.model("Community", communitySchema); // Mongoose model

// API Route to fetch communities
app.get("/api/communities", async (req, res) => {
  try {
    const communities = await Community.find();
    if (communities.length === 0) {
      console.log("No communities found.");
      return res.status(404).json({ error: "No communities found" });
    }
    console.log("Fetched communities:", communities);
    res.json(communities);
  } catch (error) {
    console.error("Error fetching communities:", error);
    res.status(500).json({ error: "Failed to fetch communities" });
  }
});

// Start the server
app.listen(3000, () =>
  console.log("Server running on http://localhost:3000")
);
