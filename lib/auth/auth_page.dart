import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../start_page.dart';
import '../mentor/mentor_pending_approval.dart';



enum AuthMode { login, signup }
enum UserType { student, mentor, investor }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthMode _mode = AuthMode.login;
  UserType _selectedType = UserType.student;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF5AC8FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.rocket_launch, size: 36),
              ),

              const SizedBox(height: 16),

              const Text(
                'MentorConnectX',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Connect. Learn. Grow.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // Login / Signup Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _toggleButton('Login', AuthMode.login),
                    _toggleButton('Sign Up', AuthMode.signup),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_mode == AuthMode.signup) _userTypeSelector(),

              if (_mode == AuthMode.signup)
                _inputField(
                  controller: _nameController,
                  hint: 'Full Name',
                  icon: Icons.person,
                ),

              _inputField(
                controller: _emailController,
                hint: 'Email Address',
                icon: Icons.email,
              ),

              _inputField(
                controller: _passwordController,
                hint: _mode == AuthMode.login
                    ? 'Password'
                    : 'Create Password',
                icon: Icons.lock,
                obscure: true,
              ),

              if (_mode == AuthMode.login)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),

              const SizedBox(height: 16),

              // Main Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A2A43),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: _handlePrimaryAction,
                  child: Text(
                    _mode == AuthMode.login ? 'Login' : 'Create Account',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Widgets ----------

  Widget _toggleButton(String label, AuthMode mode) {
    final bool active = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _userTypeSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _roleCard(UserType.student, Icons.school, 'Student'),
          _roleCard(UserType.mentor, Icons.person_outline, 'Mentor'),
          _roleCard(UserType.investor, Icons.trending_up, 'Investor'),
        ],
      ),
    );
  }

  Widget _roleCard(UserType type, IconData icon, String label) {
    final bool selected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF5AC8FA) : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? const Color(0xFF5AC8FA) : Colors.grey),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ---------- Logic ----------

  Future<void> _handlePrimaryAction() async {
  try {
    // ================= LOGIN =================
    if (_mode == AuthMode.login) {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = cred.user!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw 'User record not found';
      }

      final data = doc.data()!;
      final String role = data['role'];
      final bool verified = data['verified'] ?? false;

      if (!mounted) return;

      // 🔒 Block UNVERIFIED students & mentors
      if ((role == 'student' || role == 'mentor') && !verified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MentorPendingApprovalPage(),
          ),
        );
        return;
      }

      // ✅ Admin OR verified users → onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StartPage(role: role),
        ),
      );

      return;
    }

    // ================= SIGN UP =================
    if (_selectedType == UserType.investor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Investor signup will be available later'),
        ),
      );
      return;
    }

    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final uid = cred.user!.uid;

    final String role =
        _selectedType == UserType.mentor ? 'mentor' : 'student';

    // 🔒 ALWAYS unverified at signup
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'role': role,
      'verified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    // 🔒 BOTH student & mentor → pending approval
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MentorPendingApprovalPage(),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}




}