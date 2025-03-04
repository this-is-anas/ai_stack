import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new post
  Future<void> createPost({
    required String content,
    required String userId,
    required String userName,
    required String userImagePath,
  }) async {
    await _firestore.collection('posts').add({
      'content': content,
      'authorId': userId,
      'authorName': userName,
      'authorImage': userImagePath,
      'likes': 0,
      'likedBy': [],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get real-time stream of posts
  Stream<QuerySnapshot> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .where('userId', isNotEqualTo: null)
        .limit(50)
        .snapshots(includeMetadataChanges: true);
  }

  // Like/unlike a post
  Future<void> toggleLike(String postId, String userId) async {
    final docRef = _firestore.collection('posts').doc(postId);

    return _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      final likedBy = List<String>.from(doc['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        transaction.update(docRef, {
          'likes': doc['likes'] - 1,
          'likedBy': FieldValue.arrayRemove([userId])
        });
      } else {
        transaction.update(docRef, {
          'likes': doc['likes'] + 1,
          'likedBy': FieldValue.arrayUnion([userId])
        });
      }
    });
  }

  // Add comment to a post
  Future<void> addComment(String postId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final commentRef =
        _firestore.collection('posts').doc(postId).collection('comments').doc();

    await commentRef.set({
      'userId': user.uid,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update comment count
    await _firestore.collection('posts').doc(postId).update({
      'comments': FieldValue.increment(1),
    });
  }

  // Get user profile data
  Future<DocumentSnapshot> getUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }
}
