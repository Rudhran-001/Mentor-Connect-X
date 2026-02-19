import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorProfilePage extends StatefulWidget {
  const MentorProfilePage({super.key});

  @override
  State<MentorProfilePage> createState() => _MentorProfilePageState();
}

class _MentorProfilePageState extends State<MentorProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _experienceController = TextEditingController();
  final _domainController = TextEditingController();
  final _companyController = TextEditingController();
  final _skillsController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final profile = doc.data()?['profile'];

    if (profile != null) {
      _nameController.text = profile['fullName'] ?? '';
      _experienceController.text = profile['experienceYears']?.toString() ?? '';
      _domainController.text = profile['domain'] ?? '';
      _companyController.text = profile['company'] ?? '';
      _skillsController.text = (profile['skills'] as List?)?.join(', ') ?? '';
      _bioController.text = profile['bio'] ?? '';
      _linkedinController.text = profile['linkedin'] ?? '';
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
          'experienceYears': int.tryParse(_experienceController.text.trim()) ?? 0,
          'domain': _domainController.text.trim(),
          'company': _companyController.text.trim(),
          'skills': _skillsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          'bio': _bioController.text.trim(),
          'linkedin': _linkedinController.text.trim(),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _saveProfile,
        backgroundColor: Colors.black,
        icon: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(_saving ? 'Saving...' : 'Save Changes', style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Extra bottom padding for FAB
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : '?',
                        style: TextStyle(fontSize: 40, color: Colors.grey[800], fontWeight: FontWeight.bold),
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

              _SectionHeader(title: 'Personal Info'),
              _ModernField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              _ModernField(
                label: 'Bio',
                controller: _bioController,
                icon: Icons.info_outline,
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: 'Professional Details'),
              Row(
                children: [
                  Expanded(
                    child: _ModernField(
                      label: 'Experience (Yrs)',
                      controller: _experienceController,
                      icon: Icons.work_history_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ModernField(
                      label: 'Domain',
                      controller: _domainController,
                      icon: Icons.category_outlined,
                    ),
                  ),
                ],
              ),
              _ModernField(
                label: 'Company',
                controller: _companyController,
                icon: Icons.business_outlined,
              ),
              _ModernField(
                label: 'Skills (comma separated)',
                controller: _skillsController,
                icon: Icons.auto_awesome_outlined,
                helperText: 'e.g. Flutter, Leadership, Marketing',
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: 'Social'),
              _ModernField(
                label: 'LinkedIn Profile URL',
                controller: _linkedinController,
                icon: Icons.link,
                keyboardType: TextInputType.url,
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
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
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
  final TextInputType keyboardType;
  final String? helperText;

  const _ModernField({
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.isEmpty ? '$label is required' : null,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
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