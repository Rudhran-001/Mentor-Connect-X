import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';

class StartChatPage extends StatelessWidget {
  const StartChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Modern light background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'New Message',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text("User profile error"));
          }

          final role = snap.data!['role'];
          final targetRole = role == 'student' ? 'mentor' : 'student';

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: targetRole)
                .where('verified', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              final users = snapshot.data?.docs ?? [];

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_rounded,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No $targetRole\s found',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for new people.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = users[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Unnamed';
                  final email = data['email'] ?? '';

                  return _UserCard(
                    name: name,
                    email: email,
                    role: targetRole,
                    onTap: () async {
                      // Show loading dialog or indicator if needed, 
                      // sticking to basic flow for now
                      final chatId = await _getOrCreateChat(
                        currentUid: uid,
                        otherUid: doc.id,
                        role: role,
                      );

                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(chatId: chatId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _getOrCreateChat({
    required String currentUid,
    required String otherUid,
    required String role,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final query = role == 'mentor'
        ? firestore
            .collection('chats')
            .where('mentorId', isEqualTo: currentUid)
            .where('studentId', isEqualTo: otherUid)
        : firestore
            .collection('chats')
            .where('mentorId', isEqualTo: otherUid)
            .where('studentId', isEqualTo: currentUid);

    final existing = await query.get();
    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final doc = await firestore.collection('chats').add({
      'mentorId': role == 'mentor' ? currentUid : otherUid,
      'studentId': role == 'student' ? currentUid : otherUid,
      'createdBy': currentUid,
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
      'lastMessage': null,
      'lastMessageAt': null,
    });

    return doc.id;
  }
}

class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final VoidCallback onTap;

  const _UserCard({
    required this.name,
    required this.email,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMentor = role == 'mentor';
    final themeColor = isMentor ? Colors.indigo : Colors.purple;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Action Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: themeColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}