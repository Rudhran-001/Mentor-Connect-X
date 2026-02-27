import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../auth/auth_page.dart';
import '../shared/student_approval_page.dart';
import '../chat/chat_list_page.dart';
import '../mentor/mentor_profile_page.dart';
import '../calls/incoming_call_page.dart';

class MentorHomePage extends StatefulWidget {
  const MentorHomePage({super.key});

  @override
  State<MentorHomePage> createState() => _MentorHomePageState();
}

class _MentorHomePageState extends State<MentorHomePage> {
  StreamSubscription<QuerySnapshot>? _callSubscription;
  bool _isHandlingCall = false;

  @override
void initState() {
  super.initState();

  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid != null) {
    _callSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) {

      if (snapshot.docs.isNotEmpty && !_isHandlingCall) {
        _isHandlingCall = true;

        final callDoc = snapshot.docs.first;
        final callId = callDoc.id;
        final chatId = callDoc['chatId'];

        final callType = callDoc.data().containsKey('type')
            ? callDoc['type']
            : 'voice';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncomingCallPage(
              callId: callId,
              chatId: chatId,
              callType: callType,
            ),
          ),
        ).then((_) {
          _isHandlingCall = false;
        });
      }
    });
  }
}

  @override
void dispose() {
  _callSubscription?.cancel();
  super.dispose();
}

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Mentor Workspace',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            _HomeCard(
              title: 'Chats',
              subtitle: 'Message students',
              icon: Icons.forum_rounded,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatListPage(),
                  ),
                );
              },
            ),
            _HomeCard(
              title: 'Verify Students',
              subtitle: 'Approve accounts',
              icon: Icons.how_to_reg_rounded,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentApprovalPage(),
                  ),
                );
              },
            ),
            _HomeCard(
              title: 'My Profile',
              subtitle: 'Edit details',
              icon: Icons.account_circle_rounded,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MentorProfilePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}