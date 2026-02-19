import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final Timestamp? sentAt;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.sentAt,
  });

  @override
  Widget build(BuildContext context) {
    final time = sentAt != null
        ? DateFormat('hh:mm a').format(sentAt!.toDate())
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
