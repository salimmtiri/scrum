import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
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

  // This is where we define _pages list
  List<Widget> _buildPages() {
    return [
      HomePageContent(communities: _communities),
      Center(child: Text('Communities', style: TextStyle(color: Colors.white))),
      Center(child: Text('Create', style: TextStyle(color: Colors.white))),
      Center(child: Text('Chat', style: TextStyle(color: Colors.white))),
      Center(child: Text('Inbox', style: TextStyle(color: Colors.white))),
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
          icon: Icon(Icons.menu, color: Colors.white),
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
                return Icon(Icons.image_not_supported, color: Colors.red);
              },
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile clicked!')),
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
            DrawerHeader(
              child: Text(
                'Communities',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
            ListTile(
              leading: Icon(Icons.add, color: Colors.white),
              title: Text('Create a Community',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigate to create community')),
                );
              },
            ),
            Divider(color: Colors.grey),
            ..._communities.map((community) {
              return ListTile(
                title: Text(
                  community.name,
                  style: TextStyle(color: Colors.white),
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

  HomePageContent({required this.communities});

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

  CommunityCard({required this.community});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              community.name,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
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

class PostCard extends StatefulWidget {
  final Post post;

  PostCard({required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _upvotes = 0;
  int _downvotes = 0;

  @override
  void initState() {
    super.initState();
    _upvotes = widget.post.upvotes;
    _downvotes = widget.post.downvotes;
  }

  void _incrementUpvote() {
    setState(() {
      _upvotes++;
    });
  }

  void _incrementDownvote() {
    setState(() {
      _downvotes++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.white, width: 1.0),
      ),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 8.0),
                Text(
                  'Username',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  '2 hours ago',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Text(
              widget.post.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.0),
            Text(
              widget.post.content,
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: Colors.white),
                      onPressed: _incrementUpvote,
                    ),
                    Text(
                      '$_upvotes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_down, color: Colors.white),
                      onPressed: _incrementDownvote,
                    ),
                    Text(
                      '$_downvotes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  '${widget.post.commentsCount} comments',
                  style: TextStyle(color: Colors.white),
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
  final String title;
  final String content;
  final int upvotes;
  final int downvotes;
  final int commentsCount;

  Post({
    required this.title,
    required this.content,
    required this.upvotes,
    required this.downvotes,
    required this.commentsCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
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
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
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
