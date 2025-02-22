import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../login/login_page.dart';
import 'edit_profile_page.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _name = "John Doe";
  String? _email;
  String? _profileImageUrl;
  String? _bio;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future _loadUserData() async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return;
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _name = data['name'] ?? 'John Doe';
          _email = data['email'] ?? '';
          _bio = data['bio'] ?? '';
          _profileImageUrl = data['profileImage'];
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future _navigateToEditProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
    if (updatedData != null && updatedData is Map) {
      setState(() {
        _name = updatedData['name'];
        _email = updatedData['email'];
        _bio = updatedData['bio'];
      });
    }
  }

  Future _logout() async {
    await _auth.signOut(); // Logs out from Firebase
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false, // Removes all previous routes from stack
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withOpacity(0.1),
              colors.secondary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildProfileAvatar(theme),
                const SizedBox(height: 32),
                _buildProfileInfoCard(theme),
                const SizedBox(height: 24),
                _buildActionButtons(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(ThemeData theme) {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_profileImageUrl ??
            'https://opboempdoytuyavetqko.supabase.co/storage/v1/object/public/avatars/default_avatar.png'),
      ),
    );
  }

  Widget _buildProfileInfoCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileInfoRow(Icons.person, 'Name', _name ?? 'Guest User'),
            const Divider(),
            _buildProfileInfoRow(
                Icons.email, 'Email', _email ?? 'no-email@example.com'),
            const Divider(),
            _buildProfileInfoRow(Icons.info, 'Bio', _bio ?? 'No bio added yet'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.poppins(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        _buildGradientButton(
          icon: Icons.edit,
          label: 'Edit Profile',
          onPressed: _navigateToEditProfile,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildGradientButton(
          icon: Icons.logout,
          label: 'Log Out',
          onPressed: _logout,
          theme: theme,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
    Color? color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: color != null
              ? [color, color]
              : [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (color ?? theme.colorScheme.primary).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
          ],
        ),
      ),
    );
  }
}
