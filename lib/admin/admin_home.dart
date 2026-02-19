import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_page.dart';
import 'mentor_approval_page.dart';
import '../shared/student_approval_page.dart';
import '../chat/chat_list_page.dart';
import 'admin_user_list_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              onPressed: () => _logout(context),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const Text(
              'System Overview',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // Grid Layout for a more modern "Dashboard" feel
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _AdminCard(
                  title: 'Chats',
                  icon: Icons.forum_rounded,
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListPage())),
                ),
                _AdminCard(
                  title: 'Mentor Approvals',
                  icon: Icons.verified_user_rounded,
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MentorApprovalPage())),
                ),
                _AdminCard(
                  title: 'Student Approvals',
                  icon: Icons.school_rounded,
                  color: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentApprovalPage())),
                ),
                _AdminCard(
                  title: 'View Students',
                  icon: Icons.people_alt_rounded,
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserListPage(role: 'student'))),
                ),
                _AdminCard(
                  title: 'View Mentors',
                  icon: Icons.psychology_rounded,
                  color: Colors.indigo,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserListPage(role: 'mentor'))),
                ),
                _AdminCard(
                  title: 'Reports',
                  icon: Icons.analytics_rounded,
                  color: Colors.grey,
                  onTap: () {}, // Future feature
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}