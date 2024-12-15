const mongoose = require('mongoose');

const CommentSchema = new mongoose.Schema({
  postId: { type: mongoose.Schema.Types.ObjectId, ref: 'Post', required: true }, // Reference to Post model
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Reference to User model
  content: { type: String, required: true },
  upvotes: { type: Number, default: 0 },
  downvotes: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
  status: { type: String, enum: ['active', 'inactive', 'flagged'], default: 'active' },
  replyTo: { type: mongoose.Schema.Types.ObjectId, ref: 'Comment', default: null }, // For replies
});

module.exports = mongoose.model('Comment', CommentSchema);
