import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class CommunityPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime timestamp;

  CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.timestamp,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CommunityPost(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'Anonymous',
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
    );
  }
}
