import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_community.dart';
import 'comments.dart';

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
  bool _hasVoted = false;

  String _selectedReason = 'Harassment';
  TextEditingController _complaintController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _upvotes = widget.post.upvotes;
    _downvotes = widget.post.downvotes;
  }

  void _vote(String type) {
    if (_hasVoted) return; // Prevent multiple votes

    setState(() {
      if (type == "upvote") {
        _upvotes++;
      } else if (type == "downvote") {
        _downvotes++;
      }
      _hasVoted = true;
    });
  }

  Future<void> _submitReport() async {
    if (_complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a complaint')),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('http://localhost:3000/api/report'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode({
          'postId': widget.post.id,
          'userId':
              '6731f5139835ddd090352a7d', // You might want to use actual user id
          'reason': _selectedReason,
          'complaint': _complaintController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context); // Close the modal on success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post reported successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to report the post')),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while submitting the report')),
      );
    }
  }

  void _showReportDialog() {
    // This will open a modal bottom sheet with the "Report" button
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Report this post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedReason,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReason = newValue!;
                  });
                },
                items: <String>['Harassment', 'Annoying', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _complaintController,
                decoration: InputDecoration(
                  labelText: 'Complaint (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitReport,
                child: Text('Submit Report'),
              ),
            ],
          ),
        );
      },
    );
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
                // Three vertical dots button
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _showReportDialog, // Show pop-up on click
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              widget.post.content,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up, color: Colors.green),
                  onPressed: () => _vote("upvote"),
                ),
                Text("$_upvotes", style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 10.0),
                IconButton(
                  icon: const Icon(Icons.thumb_down, color: Colors.red),
                  onPressed: () => _vote("downvote"),
                ),
                Text("$_downvotes",
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: () {
                    // Navigate to CommentsPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CommentsPage(postId: widget.post.id),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.white),
                      Text(
                        widget.post.commentsCount.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
