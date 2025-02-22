import 'package:ai_hub/pages/model/post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

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
            Row(
              children: [
                _buildAuthorImage(post.authorImage),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(DateFormat('MMM dd, HH:mm').format(post.timestamp),
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 12),
            Text(post.content,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorImage(String? imagePath) {
    return FutureBuilder<ImageProvider>(
      future: _getAuthorImage(imagePath),
      builder: (context, snapshot) {
        return CircleAvatar(
          radius: 20,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: snapshot.hasData && snapshot.data is! AssetImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image(image: snapshot.data!),
                )
              : Icon(
                  Icons.person,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
        );
      },
    );
  }

  Future<ImageProvider> _getAuthorImage(String? imagePath) async {
    if (imagePath == null) {
      return const AssetImage('lib/assets/images/transparent.png');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$imagePath');
      if (await file.exists()) {
        return FileImage(file);
      }
    } catch (e) {
      print('Error loading author image: $e');
    }

    return const AssetImage('lib/assets/images/transparent.png');
  }
}
