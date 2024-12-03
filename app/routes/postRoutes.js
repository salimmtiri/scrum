const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();
const Community = require("../models/community"); // Assuming you have a Community model

router.post("/vote", async (req, res) => {
    const { postId, type } = req.body;

    // Validate input
    if (!postId || !["upvote", "downvote"].includes(type)) {
        return res.status(400).json({ error: "Invalid request data" });
    }

    try {
        // Convert postId to ObjectId using 'new'
        const postIdObjectId = new mongoose.Types.ObjectId(postId);

        // Log the postId being searched for debugging
        console.log("Request to vote: postId=" + postId + ", type=" + type);

        // Find the community that contains the post by checking all communities
        const communities = await Community.find({ "posts.id": postIdObjectId }).exec();

        // Log the result of the community query
        if (communities.length === 0) {
            return res.status(404).json({ error: "Community not found" });
        }
        
        console.log("Found communities: ", communities.map(community => community.name));

        // Loop through all found communities and their posts
        let postFound = false;
        let updatedPost = null;

        for (const community of communities) {
            const postIndex = community.posts.findIndex(post => post.id.equals(postIdObjectId));

            if (postIndex !== -1) {
                // Post found, update votes
                const post = community.posts[postIndex];
                if (type === "upvote") {
                    post.upvotes += 1;
                } else if (type === "downvote") {
                    post.downvotes += 1;
                }
                updatedPost = post;
                postFound = true;
                await community.save();
                break; // exit once the post is updated
            }
        }

        if (!postFound) {
            return res.status(404).json({ error: "Post not found" });
        }

        res.status(200).json({
            success: true,
            updatedCount: type === "upvote" ? updatedPost.upvotes : updatedPost.downvotes
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
