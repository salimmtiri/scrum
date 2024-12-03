const mongoose = require("mongoose");

// Define the Post schema
const postSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  content: {
    type: String,
    required: true,
  },
  upvotes: {
    type: Number,
    default: 0,
  },
  downvotes: {
    type: Number,
    default: 0,
  },
  commentsCount: {
    type: Number,
    default: 0,
  },
  // Define the 'id' field as ObjectId
  id: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    unique: true, // Ensure each post has a unique 'id'
  },
});

// Define the Community schema
const communitySchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    theme: { type: String, required: true }, // The theme field
    owner: { type: String, default: '6731f5139835ddd090352a7d' }, // Static owner field
    posts: {
      type: [postSchema], // Posts are now an array of post objects
      default: [],
    },
  },
  { collection: "communityDB", versionKey: false }
);

// Create the Community model
const Community = mongoose.model("Community", communitySchema);

module.exports = Community;
