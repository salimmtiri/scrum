const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Comment = require('../models/commentmodel');
const Community = require('../models/community');

router.post('/add-comment', async (req, res) => {
    try {
      const { postId, userId, content, replyTo } = req.body;
  
      // Check if all required fields are provided
      if (!postId || !userId || !content) {
        return res.status(400).json({ error: "postId, userId, and content are required" });
      }
  
      // Correct way to instantiate ObjectId
      const postIdObject = new mongoose.Types.ObjectId(postId);
  
      // Validate the format of postId
      if (!mongoose.Types.ObjectId.isValid(postIdObject)) {
        return res.status(400).json({ error: "Invalid postId format" });
      }
  
      // Find the community document
      const community = await Community.findOne({ 'posts.id': postIdObject });
  
      if (!community) {
        return res.status(404).json({ error: "Community or Post not found" });
      }
  
      // Find the specific post from the posts array
      const post = community.posts.find(p => p.id.toString() === postIdObject.toString());
  
      if (!post) {
        return res.status(404).json({ error: "Post not found" });
      }
  
      // Create a new comment
      const newComment = new Comment({
        postId: postIdObject,  // Use postIdObject here
        userId,
        content,
        replyTo: replyTo ? new mongoose.Types.ObjectId(replyTo) : null,
      });
  
      // Save the comment to the database
      await newComment.save();
  
      // Add the comment count to the post
      post.commentsCount += 1;
      await community.save();
  
      // Respond with success message and comment details
      res.status(201).json({
        message: 'Comment added successfully',
        comment: newComment
      });
    } catch (err) {
      console.error('Error adding comment:', err);
      res.status(500).json({ error: 'Failed to add comment' });
    }
  });
  


  router.get('/comments/:postId', async (req, res) => {
    try {
      const postId = req.params.postId;
  
      console.log(`Received postId: ${postId}`);
      if (!mongoose.Types.ObjectId.isValid(postId)) {
        return res.status(400).json({ error: 'Invalid postId format' });
      }
  
      const postObjectId = new mongoose.Types.ObjectId(postId);
  
      // Use MongoDB aggregation to join with the users collection
      const comments = await Comment.aggregate([
        {
          $match: { postId: postObjectId }, // Match comments with the given postId
        },
        {
          $lookup: {
            from: 'users', // Name of the users collection
            localField: 'userId', // Field in the comments collection
            foreignField: '_id', // Field in the users collection
            as: 'userDetails', // Output field with user data
          },
        },
        {
          $unwind: { // Flatten the userDetails array (optional)
            path: '$userDetails',
            preserveNullAndEmptyArrays: true, // Keep comments even if user not found
          },
        },
        {
          $project: {
            _id: 1,
            content: 1,
            replyTo: 1,
            postId: 1,
            userId: 1,
            pseudo: '$userDetails.pseudo', // Include pseudo from userDetails
          },
        },
      ]);
  
      console.log('Aggregated comments:', comments);
  
      if (comments.length === 0) {
        return res.status(404).json({ message: 'No comments found for this post' });
      }
  
      res.json(comments);
    } catch (err) {
      console.error('Error fetching comments:', err);
      res.status(500).json({ error: 'Failed to fetch comments' });
    }
  });
  
module.exports = router;
