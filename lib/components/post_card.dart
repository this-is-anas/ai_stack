import 'package:ai_hub/pages/model/post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;

  const PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 8),
            Text(post.content),
            SizedBox(height: 8),
            Row(
              children: [
                Text(post.author, style: TextStyle(color: Colors.grey)),
                Spacer(),
                Text(DateFormat('MMM dd, yyyy').format(post.timestamp),
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
