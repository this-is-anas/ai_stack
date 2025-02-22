import 'package:ai_hub/pages/model/post.dart';
import 'package:ai_hub/pages/services/community_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_hub/components/post_card.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final CommunityService _communityService = CommunityService();

  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Community Feed'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeDialog(context),
        child: Icon(Icons.edit),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
          stream: _communityService.getPosts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No posts yet!'));
            }

            final posts = snapshot.data!.docs
                .map((doc) => CommunityPost.fromFirestore(doc))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(post: post);
              },
            );
          },
        ),
      ),
    );
  }

  // Widget _buildComposeCard(ColorScheme colors) {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(20),
  //       side: BorderSide(color: colors.primary.withOpacity(0.1)),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               const CircleAvatar(
  //                 radius: 20,
  //                 backgroundImage: AssetImage('lib/assets/images/google.png'),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: TextField(
  //                   controller: _postController,
  //                   maxLines: null,
  //                   decoration: InputDecoration(
  //                     hintText: 'Start a discussion...',
  //                     border: InputBorder.none,
  //                     hintStyle:
  //                         TextStyle(color: colors.onSurface.withOpacity(0.4)),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           Align(
  //             alignment: Alignment.centerRight,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   colors: [colors.primary, colors.secondary],
  //                 ),
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //               child: TextButton(
  //                 onPressed: () => _createPost(_postController.text),
  //                 style: TextButton.styleFrom(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 24, vertical: 12),
  //                 ),
  //                 child: Text(
  //                   'Post',
  //                   style: GoogleFonts.poppins(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    super.dispose();
  }

  void _createPost(String content) {
    if (content.isEmpty || !mounted) return;
    final userId = _currentUser?.uid;
    if (userId == null) return;

    _firestore.collection('users').doc(userId).get().then((userDoc) {
      // Handle missing user document case
      final userData = userDoc.data() ?? {};

      _communityService.createPost(
        content: content,
        userId: userId,
        userName: userData['name'] ?? _currentUser?.displayName ?? 'Anonymous',
        userImagePath: userData['profileImage'] ?? 'default_avatar.png',
      );
    }).catchError((error) {
      print('Error creating post: $error');
    });
  }

  void _showComposeDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: _currentUser?.photoURL != null
                        ? NetworkImage(_currentUser!.photoURL!)
                        : null,
                    child: _currentUser?.photoURL == null
                        ? Icon(Icons.person)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Text(
                    _currentUser?.displayName ?? 'Anonymous',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "What's happening?",
                  border: InputBorder.none,
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _createPost(_controller.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Post'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
