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
  String? _jobPreferences;
  File? _profileImage;
  String? _bio;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLocalImage();
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
          _jobPreferences = data['jobPreferences'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future _loadLocalImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userId = _auth.currentUser?.uid ?? '';
      final path = '${directory.path}/profile_$userId.jpg';
      final file = File(path);
      if (await file.exists()) {
        setState(() {
          _profileImage = file;
        });
      }
    } catch (e) {
      print('Error loading local image: $e');
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
        _jobPreferences = updatedData['jobPreferences'];
      });
    }
    _loadLocalImage();
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
      body: SingleChildScrollView(
        child: Container(
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
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildProfileHeader(theme),
                const SizedBox(height: 32),
                _buildProfileCard(theme),
                const SizedBox(height: 24),
                _buildActionButtons(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
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
            CircleAvatar(
              radius: 40,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : const AssetImage('lib/assets/images/google.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(_name ?? 'Guest User',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                )),
            Text(_email ?? 'no-email@example.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
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
          _buildInfoRow(Icons.info, 'Bio', _bio ?? 'No bio added yet'),
          const Divider(),
          _buildInfoRow(Icons.location_on, 'Location', 'New York, USA'),
          const Divider(),
          _buildInfoRow(Icons.calendar_today, 'Member Since', '2023'),
        ],
      ),
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

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: GoogleFonts.poppins(fontSize: 16)),
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
