const mongoose = require("mongoose");

// MongoDB connection
mongoose.connect("mongodb://localhost:27017/communityDB", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const postSchema = new mongoose.Schema({
  title: String,
  content: String,
  upvotes: Number,
  downvotes: Number,
  commentsCount: Number,
});

const communitySchema = new mongoose.Schema({
  name: String,
  posts: [postSchema],
});

const Community = mongoose.model("Community", communitySchema);

const seedData = [
  {
    name: "Flutter Community",
    posts: [
      {
        title: "Flutter 3.0 Released!",
        content: "Here are the details of Flutter 3.0...",
        upvotes: 120,
        downvotes: 3,
        commentsCount: 15,
      },
      {
        title: "Best practices for Flutter development",
        content: "This post outlines the best practices...",
        upvotes: 95,
        downvotes: 2,
        commentsCount: 8,
      },
    ],
  },
  {
    name: "Programming Community",
    posts: [
      {
        title: "How to become a better programmer",
        content: "The path to becoming a better programmer...",
        upvotes: 200,
        downvotes: 5,
        commentsCount: 30,
      },
    ],
  },
];

// Insert data into MongoDB
Community.insertMany(seedData)
  .then(() => {
    console.log("Data inserted successfully");
    mongoose.connection.close();
  })
  .catch((error) => {
    console.error("Error inserting data:", error);
    mongoose.connection.close();
  });
