// index.js
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const communityRoutes = require('./app/routes/communityRoutes'); // Import the community routes
const postRoutes = require("./app/routes/postRoutes");
const commentroute = require("./app/routes/commentroute");
const cors = require('cors');


const app = express();
app.use(cors({
  origin: 'http://localhost:3000',  // Replace with your Flutter web app's URL
}));
// Middleware to parse JSON requests
app.use(bodyParser.json());

// MongoDB connection URI (use your own URI if different)
const mongoURI = 'mongodb://localhost:27017/iteam'; // Change this to your MongoDB URI

// Connect to MongoDB
mongoose.connect(mongoURI)
  .then(() => {
    console.log('MongoDB connected successfully!');
  })
  .catch((error) => {
    console.error('Error connecting to MongoDB:', error);
    process.exit(1);  // Exit the process if connection fails
  });


// Use the community routes for the API
app.use('/api', communityRoutes); 
app.use("/api", postRoutes); // Prefix your routes with `/api`
app.use("/api",commentroute)
// Set the port and start the server
const PORT = process.env.PORT || 3000;  // You can set this to any available port
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
