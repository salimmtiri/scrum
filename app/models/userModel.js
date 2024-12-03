const mongoose = require('mongoose');

// Define the user schema
const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,  // Ensures email is unique
    trim: true,    // Trims whitespace
  },
  password: {
    type: String,
    required: true,
  },
  pseudo: {
    type: String,
    required: true,
    trim: true,
  },
  sexe: {
    type: String,
    required: true,
    enum: ['Homme', 'Femme'],  // Only allows 'Homme' or 'Femme'
  },
  avatar: {
    type: String,
    required: false,  // Avatar is optional
  },
  centresInteret: [
    {
      type: mongoose.Schema.Types.ObjectId,  // This links to the CentreInteret model
      ref: 'CentreInteret',  // This references the CentreInteret model
    }
  ]
}, {
  timestamps: true,  // Automatically adds createdAt and updatedAt fields
});

// Create the User model
const User = mongoose.model('User', userSchema);

module.exports = User;
