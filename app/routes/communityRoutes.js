// routes/communityRoutes.js
const express = require('express');
const router = express.Router();
const Community = require('../models/community');
const User = require('../models/userModel');
const CentreInteret = require('../models/centreInteretModel'); // Updated model name

// Create a new community
router.post('/community', async (req, res) => {
  const { name, theme } = req.body;

  if (!name || !theme) {
    return res.status(400).json({ error: "Name and theme are required fields" });
  }

  try {
    const community = new Community({ name, theme });
    await community.save();
    res.status(201).json({ message: 'Community created successfully', community });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create community', details: error.message });
  }
});

router.get('/communities', async (req, res) => {
  try {
    const userId = '673c66c07fb1ea98ec882d1e';  // Static user ID for now

    // Fetch the user by ID
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Log the user object to check if 'centresInteret' is correctly populated
    console.log("User:", user);

    // Fetch the themes (centreInteret) for the user
    const centresInteretIds = user.centresInteret;
    console.log("User Interests (centreInteret IDs):", centresInteretIds);

    if (!centresInteretIds || centresInteretIds.length === 0) {
      return res.status(404).json({ error: 'User does not have any interests (centresInteret)' });
    }

    // Fetch the themes corresponding to the interests
    const interests = await CentreInteret.find({ _id: { $in: centresInteretIds } });
    console.log("Interests (Themes):", interests);

    if (!interests || interests.length === 0) {
      return res.status(404).json({ error: 'No matching interests found in the database' });
    }

    // Extract themes from the interests
    const themes = interests.map(interest => interest.theme);
    console.log("Extracted Themes:", themes);

    if (!themes || themes.length === 0) {
      return res.status(404).json({ error: 'No themes found for user interests' });
    }

    // Fetch communities matching the themes
    const communities = await Community.find({ theme: { $in: themes } });
    console.log("Matching Communities:", communities);

    if (!communities || communities.length === 0) {
      return res.status(404).json({ error: 'No communities found for the user interests' });
    }

    res.status(200).json(communities);
  } catch (error) {
    console.error('Error fetching communities:', error);
    res.status(500).json({
      error: 'Failed to fetch communities',
      details: error.message,
    });
  }
});

module.exports = router;
