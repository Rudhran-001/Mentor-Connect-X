import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';
import 'start_chat_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light modern background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StartChatPage(),
            ),
          );
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text('New Chat', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (!userSnap.hasData || userSnap.data == null) {
            return const Center(child: Text("User data not available"));
          }

          final role = userSnap.data!['role'];

          Query query;
          if (role == 'admin') {
            query = FirebaseFirestore.instance.collection('chats');
          } else if (role == 'mentor') {
            query = FirebaseFirestore.instance
                .collection('chats')
                .where('mentorId', isEqualTo: uid);
          } else {
            query = FirebaseFirestore.instance
                .collection('chats')
                .where('studentId', isEqualTo: uid);
          }

          return StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mark_chat_unread_outlined,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a conversation to see it here.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              final chats = snapshot.data!.docs;

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: chats.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final data = chat.data() as Map<String, dynamic>;
                  final lastMsg = data['lastMessage'] ?? 'New chat';
                  // Displaying the last 4 chars of ID as a visual tag since we don't have names in this specific query
                  final shortId = chat.id.length > 4 
                      ? chat.id.substring(chat.id.length - 4).toUpperCase() 
                      : chat.id;

                  return _ChatCard(
                    message: lastMsg,
                    chatIdTag: shortId,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(chatId: chat.id),
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
}

class _ChatCard extends StatelessWidget {
  final String message;
  final String chatIdTag;
  final VoidCallback onTap;

  const _ChatCard({
    required this.message,
    required this.chatIdTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                // Avatar Placeholder
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                // Message Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chat Room', // Placeholder for Name
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$chatIdTag',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}