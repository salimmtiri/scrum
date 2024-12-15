const express = require("express");
const router = express.Router();
const Report = require("../models/Report");

router.post("/report", async (req, res) => {
  try {
    const { postId, userId, reason, complaint } = req.body;
    
    const newReport = new Report({
      postId,
      userId,
      reason,
      complaint,
    });
    
    await newReport.save();
    res.status(201).json({ message: "Report submitted successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to submit report" });
  }
});

module.exports = router;
