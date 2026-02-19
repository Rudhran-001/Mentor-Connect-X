import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _educationController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final profile = doc.data()?['profile'];

    if (profile != null) {
      _nameController.text = profile['fullName'] ?? '';
      _educationController.text = profile['education'] ?? '';
      _locationController.text = profile['location'] ?? '';
      _bioController.text = profile['bio'] ?? '';
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profile': {
          'fullName': _nameController.text.trim(),
          'education': _educationController.text.trim(),
          'location': _locationController.text.trim(),
          'bio': _bioController.text.trim(),
        }
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Modern light background
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _saveProfile,
        backgroundColor: Colors.black,
        icon: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          _saving ? 'Saving...' : 'Save Changes',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Extra bottom padding for FAB
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Placeholder
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _SectionHeader(title: 'Personal Details'),
              _ModernField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_outline_rounded,
              ),
              _ModernField(
                label: 'Location',
                controller: _locationController,
                icon: Icons.location_on_outlined,
              ),
              _ModernField(
                label: 'Bio',
                controller: _bioController,
                icon: Icons.edit_note_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 16),
              _SectionHeader(title: 'Academic'),
              _ModernField(
                label: 'Education / University',
                controller: _educationController,
                icon: Icons.school_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}

class _ModernField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;

  const _ModernField({
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) => v == null || v.isEmpty ? '$label is required' : null,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
      ),
    );
  }
}