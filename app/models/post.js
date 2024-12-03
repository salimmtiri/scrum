const mongoose = require("mongoose");

const postSchema = new mongoose.Schema({
    title: { type: String, required: true },
    content: { type: String, required: true },
    upvotes: { type: Number, default: 0 },
    downvotes: { type: Number, default: 0 },
    commentsCount: { type: Number, default: 0 },
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Post", postSchema);
