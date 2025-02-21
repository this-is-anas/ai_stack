import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _jobPreferencesController;
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _resumePath;
  bool _isLoading = false;
  String? _resumeFileName;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _resumeUrl;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _jobPreferencesController = TextEditingController();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _loadUserData();
    _loadLocalImage();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _jobPreferencesController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return;
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _emailController.text = data['email'] ?? '';
          _jobPreferencesController.text = data['jobPreferences'] ?? '';
          _nameController.text = data['name'] ?? '';
          _resumeFileName = data['resumeFileName'];
          _resumeUrl = data['resumeUrl'];
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadLocalImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userId = _auth.currentUser?.uid ?? '';
      final path = '${directory.path}/profile_$userId.jpg';
      final file = File(path);
      if (await file.exists()) {
        setState(() {
          _selectedImage = file;
          _localImagePath = path;
        });
      }
    } catch (e) {
      print('Error loading local image: $e');
    }
  }

  Future<void> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userId = _auth.currentUser?.uid ?? '';
      final path = '${directory.path}/profile_$userId.jpg';
      await image.copy(path);
      setState(() {
        _selectedImage = File(path);
        _localImagePath = path;
      });
    } catch (e) {
      print('Error saving image locally: $e');
      rethrow;
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) {
        await _saveImageLocally(File(image.path));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createOrUpdateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        final String userId = _auth.currentUser?.uid ?? '';
        if (userId.isEmpty) {
          throw 'User not logged in';
        }
        final userRef = _firestore.collection('users').doc(userId);
        final docSnapshot = await userRef.get();
        if (!docSnapshot.exists) {
          await userRef.set({
            'email': _emailController.text,
            'name': _nameController.text,
            'bio': _bioController.text,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await userRef.update({
            'email': _emailController.text,
            'name': _nameController.text,
            'bio': _bioController.text,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, {
            'email': _emailController.text,
            'name': _nameController.text,
            'bio': _bioController.text,
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _createOrUpdateUserProfile,
          ),
        ],
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
                _buildAvatarSection(theme),
                const SizedBox(height: 32),
                _buildFormSection(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ThemeData theme) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Stack(
          children: [
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            if (_selectedImage == null)
              Icon(Icons.camera_alt,
                  size: 40, color: theme.colorScheme.primary),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildFormField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                theme: theme,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Bio',
                controller: _bioController,
                icon: Icons.info,
                theme: theme,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _buildGradientButton(
                  label: _isLoading ? 'Saving...' : 'Save Changes',
                  onPressed: _createOrUpdateUserProfile,
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required ThemeData theme,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.colorScheme.primary.withOpacity(0.05),
        contentPadding: const EdgeInsets.all(16),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
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
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else
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
