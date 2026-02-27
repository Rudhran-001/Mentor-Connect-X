import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../calls/voice_call_page.dart'; // Added import
import '../calls/video_call_page.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // ---------------- UPDATED APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Conversation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
  IconButton(
    icon: const Icon(Icons.call),
    onPressed: _startVoiceCall,
  ),
  IconButton(
    icon: const Icon(Icons.videocam),
    onPressed: _startVideoCall,
  ),
],
      ),
      // -----------------------------------------------
      body: Column(
        children: [
          // ---------------- MESSAGE LIST SECTION ----------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('sentAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mark_chat_unread_rounded,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == uid;

                    return _ModernMessageBubble(
                      text: data['text'] ?? '',
                      isMe: isMe,
                      sentAt: data['sentAt'],
                    );
                  },
                );
              },
            ),
          ),
          // --------------------------------------------------------------

          // INPUT UI — UNCHANGED
          Container(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(uid),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // LOGIC & HELPERS — UNCHANGED
  bool _containsRestrictedInfo(String text) {
    final phoneRegex = RegExp(r'\b\d{10}\b');
    final emailRegex =
        RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b');
    return phoneRegex.hasMatch(text) || emailRegex.hasMatch(text);
  }

  Future<void> _startVoiceCall() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final chatSnapshot = await FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.chatId)
      .get();

  final chatData = chatSnapshot.data();
  if (chatData == null) return;

  final mentorId = chatData['mentorId'];
  final studentId = chatData['studentId'];

  final receiverId =
      uid == mentorId ? studentId : mentorId;

  final callDoc = await FirebaseFirestore.instance.collection('calls').add({
    'chatId': widget.chatId,
    'callerId': uid,
    'receiverId': receiverId,
    'status': 'ringing',
    'type': 'voice', // 👈 added
    'createdAt': FieldValue.serverTimestamp(),
  });

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VoiceCallPage(
        callId: callDoc.id,
        chatId: widget.chatId,
        isCaller: true,
      ),
    ),
  );
}

Future<void> _startVideoCall() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final chatSnapshot = await FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.chatId)
      .get();

  final chatData = chatSnapshot.data();
  if (chatData == null) return;

  final mentorId = chatData['mentorId'];
  final studentId = chatData['studentId'];

  final receiverId =
      uid == mentorId ? studentId : mentorId;

  final callDoc = await FirebaseFirestore.instance.collection('calls').add({
    'chatId': widget.chatId,
    'callerId': uid,
    'receiverId': receiverId,
    'status': 'ringing',
    'type': 'video', // 👈 important
    'createdAt': FieldValue.serverTimestamp(),
  });

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VideoCallPage(
        callId: callDoc.id,
        chatId: widget.chatId,
        isCaller: true,
      ),
    ),
  );
}

  Future<void> _sendMessage(String uid) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_containsRestrictedInfo(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sharing phone numbers or email addresses is not allowed.',
          ),
        ),
      );
      return;
    }

    _controller.clear();

    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': uid,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }
}

// BUBBLE UI — UNCHANGED
class _ModernMessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final Timestamp? sentAt;

  const _ModernMessageBubble({
    required this.text,
    required this.isMe,
    this.sentAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = sentAt != null
        ? DateFormat('hh:mm a').format(sentAt!.toDate())
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blueAccent : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft:
                    isMe ? const Radius.circular(20) : const Radius.circular(4),
                bottomRight:
                    isMe ? const Radius.circular(4) : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}