import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_community.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Community> _communities = [];

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
  }

  Future<void> _fetchCommunities() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/communities'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _communities =
            data.map((community) => Community.fromJson(community)).toList();
      });
    } else {
      throw Exception('Failed to load communities');
    }
  }

  List<Widget> _buildPages() {
    return [
      HomePageContent(communities: _communities),
      const Center(
          child: Text('Communities', style: TextStyle(color: Colors.white))),
      const Center(
          child: Text('Create', style: TextStyle(color: Colors.white))),
      const Center(child: Text('Chat', style: TextStyle(color: Colors.white))),
      const Center(child: Text('Inbox', style: TextStyle(color: Colors.white))),
    ];
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 2.0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 30,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, color: Colors.red);
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile clicked!')),
                );
              },
            ),
          ],
        ),
      ),
      body: _buildPages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: Colors.black),
            label: 'Communities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, color: Colors.black),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.black),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox, color: Colors.black),
            label: 'Inbox',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Communities',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text(
                'Create a Community',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer if it's inside one
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateCommunityPage(), // Navigate to your CreateCommunityPage
                  ),
                );
              },
            ),
            const Divider(color: Colors.grey),
            ..._communities.map((community) {
              return ListTile(
                title: Text(
                  community.name,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navigating to ${community.name}')),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final List<Community> communities;

  const HomePageContent({super.key, required this.communities});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: communities.length,
      itemBuilder: (context, index) {
        return CommunityCard(community: communities[index]);
      },
    );
  }
}

class CommunityCard extends StatelessWidget {
  final Community community;

  const CommunityCard({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              community.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: community.posts.map((post) {
                return PostCard(post: post);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _upvotes = 0;
  int _downvotes = 0;
  bool _hasVoted = false; // Flag to track if the user has already voted

  @override
  void initState() {
    super.initState();
    _upvotes = widget.post.upvotes;
    _downvotes = widget.post.downvotes;
  }

  Future<void> _vote(String type) async {
    if (_hasVoted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already voted!")),
      );
      return;
    }

    final url = Uri.parse("http://localhost:3000/api/vote");

    setState(() {
      _hasVoted = true; // Set the flag to true once the user votes
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "postId": widget.post.id,
          "type": type,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          if (type == "upvote") {
            _upvotes = responseData["updatedCount"];
          } else if (type == "downvote") {
            _downvotes = responseData["updatedCount"];
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${type.capitalize()} successful!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to $type. Please try again.")),
        );
      }
    } catch (e) {
      setState(() {
        _hasVoted = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  String getRandomTime() {
    final random = Random();
    int randomMinutes = random.nextInt(1440); // Random minutes within 24 hours

    if (randomMinutes < 60) {
      return '$randomMinutes minute${randomMinutes == 1 ? '' : 's'} ago';
    } else if (randomMinutes < 1440) {
      int hours = randomMinutes ~/ 60;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else {
      int days = randomMinutes ~/ 1440;
      return '$days day${days == 1 ? '' : 's'} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title on the top left
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Time on the top right
                Text(
                  getRandomTime(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            // Post Content Preview (middle part)
            Text(
              widget.post.content,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 10.0),
            // Row for upvotes, downvotes, and comments at the bottom left
            Row(
              children: [
                // Upvote Button
                IconButton(
                  icon: const Icon(Icons.thumb_up, color: Colors.green),
                  onPressed: () => _vote("upvote"),
                ),
                Text("$_upvotes", style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 10.0),
                // Downvote Button
                IconButton(
                  icon: const Icon(Icons.thumb_down, color: Colors.red),
                  onPressed: () => _vote("downvote"),
                ),
                Text("$_downvotes",
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 10.0),
                // Comments Count
                const Icon(Icons.comment, color: Colors.white),
                Text(
                  widget.post.commentsCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Community {
  final String name;
  final List<Post> posts;

  Community({required this.name, required this.posts});

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      name: json['name'],
      posts:
          (json['posts'] as List).map((post) => Post.fromJson(post)).toList(),
    );
  }
}

class Post {
  final String id;
  final String title;
  final String content;
  final int upvotes;
  final int downvotes;
  final int commentsCount;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.upvotes,
    required this.downvotes,
    required this.commentsCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
      commentsCount: json['commentsCount'],
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Search Results for: $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(child: Text('Suggestions for: $query'));
  }
}
