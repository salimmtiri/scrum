const express = require("express");
const cors = require("cors"); // Import the CORS middleware
const bcrypt = require("bcrypt");

const app = express();
app.use(cors()); // Enable CORS for all requests
app.use(express.json());

// Simulated user data for demo purposes
const users = {
  moderator: {
    username: "moderator",
    passwordHash: bcrypt.hashSync("moderator_password", 10) // Replace with a secure password
  }
};

// Route for the root URL
app.get('/', (req, res) => {
  res.send('Welcome to the Node.js server');
});

// Login route
app.post("/login", async (req, res) => {
  const { username, password } = req.body;
  const user = users[username];

  if (user && await bcrypt.compare(password, user.passwordHash)) {
    res.send({ message: "Login successful" });
  } else {
    res.status(401).send({ message: "Invalid credentials" });
  }
});

// Protected route for the dashboard
app.get("/dashboard", (req, res) => {
  res.send({ message: "Welcome to the moderator dashboard" });
});

// Start server
app.listen(3000, () => console.log("Server running on http://localhost:3000"));
