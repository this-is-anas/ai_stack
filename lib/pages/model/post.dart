import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityPost {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorImage;
  final int likes;
  final List<String> likedBy;
  final DateTime timestamp;

  CommunityPost({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorImage,
    required this.likes,
    required this.likedBy,
    required this.timestamp,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CommunityPost(
      id: doc.id,
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorImage: data['authorImage'],
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
    );
  }
}
