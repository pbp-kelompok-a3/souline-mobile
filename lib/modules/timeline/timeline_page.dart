import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'post_model.dart';


class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => TimelinePageState();
}

class TimelinePageState extends State<TimelinePage> {
  final List<Post> _posts = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;
  // final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  // If your API requires auth, set token here (example)
  // final String? _authToken = null; // 'Bearer ey...'

  @override
  void initState() {
    super.initState();
    _fetchPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_loading && _hasMore) {
        _fetchPage();
      }
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _page = 1;
      _hasMore = true;
    });
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    if (_loading || !_hasMore) return;

    setState(() => _loading = true);

    final uri = Uri.parse('http://localhost:8000/timeline/api/timeline/?page=$_page');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      List items = body['results'] ?? [];

      final fetched = items.map((e) => Post.fromJson(e)).toList();

      setState(() {
        _posts.addAll(fetched);
        _page++;
        _hasMore = body['next'] != null;
      });
    } else {
      debugPrint("Timeline error: ${response.statusCode}");
    }

    setState(() => _loading = false);
  }


  Future<void> _toggleLike(Post post) async {
    final uri = Uri.parse('http://localhost:8000/timeline/api/post/${post.id}/like/');
    final headers = <String, String>{};
    // if (_authToken != null) headers['Authorization'] = _authToken!;

    final response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      setState(() {
        post.likedByUser = jsonBody['liked'] ?? !post.likedByUser;
        post.likeCount = jsonBody['like_count'] ?? post.likeCount + (post.likedByUser ? 1 : -1);
      });
    } else if (response.statusCode == 401) {
    // not authorized: show login
    }
  }


  Future<List<Map<String, dynamic>>> _fetchComments(int postId) async {
    final uri = Uri.parse('http://localhost:8000/timeline/api/post/$postId/comments/');
    final headers = {'Content-Type': 'application/json'};
    // if (_authToken != null) headers['Authorization'] = _authToken!;

    final res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(res.body));
    return [];
  }

  Future<bool> _addComment(int postId, String content) async {
    final uri = Uri.parse('http://localhost:8000/timeline/api/post/$postId/comment/');
    final headers = {'Content-Type': 'application/json'};
    // if (_authToken != null) headers['Authorization'] = _authToken!;

    final res = await http.post(uri, headers: headers, body: json.encode({'content': content}));
    if (res.statusCode == 201) return true;
    return false;
    }

    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xfff9f4e8),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/create_post');
          },
          backgroundColor: const Color(0xff8ecae6),
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            _header(),
            Expanded(
              child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: _posts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final post = _posts[index];
                  return _postCard(post);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff5e7fa3), Color(0xff8ecae6)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFBF0)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Text('Timeline',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  color: Color(0xFFFFFBF0),
                  fontWeight: FontWeight.bold)),
            ],
          ),  
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(fontFamily: 'Poppins'),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xffbde0fe), shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(12))),
                child: const IconButton(
                  icon: Icon(Icons.tune, color: Color(0xFFFFFBF0)),
                  onPressed: null,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _postCard(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile', arguments: post.username);
              },
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.username, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text('Lokasi', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      post.likedByUser ? Icons.favorite : Icons.favorite_border,
                      color: post.likedByUser ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleLike(post),
                  ),
                  Text('${post.likeCount}', style: const TextStyle(fontFamily: 'Poppins')),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(post.text, style: const TextStyle(fontFamily: 'Poppins')),
            const SizedBox(height: 10),
            if (post.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(post.image!, fit: BoxFit.cover),
              ),
            if (post.resourceTitle != null) _resourceCard(post),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => _openComments(post),
                ),
                Text('${post.commentCount}', style: const TextStyle(fontFamily: 'Poppins')),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _openComments(post),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Comments', style: TextStyle(fontFamily: 'Poppins')),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _resourceCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/resource', arguments: post.resourceTitle);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xfff1f1f1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (post.resourceThumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.resourceThumbnail!, width: 90, height: 60, fit: BoxFit.cover),
              ),
            const SizedBox(width: 10),
            Expanded(child: Text(post.resourceTitle ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  void _openComments(Post post) async {
    final comments = await _fetchComments(post.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: comments.length,
                    itemBuilder: (context, i) {
                      final c = comments[i];
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.grey),
                        title: Text(c['author_username'] ?? 'user'),
                        subtitle: Text(c['content'] ?? ''),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: 'Write a comment'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final content = controller.text.trim();
                        if (content.isEmpty) return;
                        final ok = await _addComment(post.id, content);
                        if (ok) {
                          Navigator.pop(context);
                          setState(() => post.commentCount + 1);
                        } else {
                        // show error
                        }
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}