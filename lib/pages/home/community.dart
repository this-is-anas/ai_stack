import 'package:ai_hub/pages/services/community_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _postController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Community',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withOpacity(0.05),
              colors.secondary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _communityService.getPostsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildComposeCard(colors);
                final post = snapshot.data!.docs[index - 1];
                return _buildPostCard(post, colors);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildComposeCard(ColorScheme colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('lib/assets/images/google.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Start a discussion...',
                      border: InputBorder.none,
                      hintStyle:
                          TextStyle(color: colors.onSurface.withOpacity(0.4)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: () => _createPost(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Post',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(DocumentSnapshot post, ColorScheme colors) {
    final data = post.data() as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final isLiked = likedBy.contains(_currentUser?.uid);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('lib/assets/images/google.png'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Enthusiast',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('@ai_user · 2h',
                        style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withOpacity(0.5))),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: colors.onSurface.withOpacity(0.4)),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Just discovered an amazing new framework for machine learning model deployment! 🚀 What\'s your favorite tool for ML ops?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked
                        ? Colors.red
                        : colors.onSurface.withOpacity(0.4),
                  ),
                  onPressed: () {
                    if (!mounted || _currentUser == null) return;
                    _communityService
                        .toggleLike(post.id, _currentUser!.uid)
                        .catchError((error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to like: $error')),
                        );
                      }
                    });
                  },
                ),
                Text('${data['likes']}',
                    style: TextStyle(color: colors.onSurface.withOpacity(0.6))),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.comment_outlined,
                      color: colors.onSurface.withOpacity(0.4)),
                  onPressed: () {},
                ),
                Text('12',
                    style: TextStyle(color: colors.onSurface.withOpacity(0.6))),
                const SizedBox(width: 20),
                Icon(Icons.share_outlined,
                    color: colors.onSurface.withOpacity(0.4)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _createPost() {
    if (_postController.text.isEmpty || !mounted) return;

    _communityService.createPost(_postController.text).then((_) {
      if (mounted) {
        _postController.clear();
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $error')),
        );
      }
    });
  }
}
