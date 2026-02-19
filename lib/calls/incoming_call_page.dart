import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'voice_call_page.dart';

class IncomingCallPage extends StatelessWidget {
  final String callId;
  final String chatId; // ✅ ADD THIS

  const IncomingCallPage({
    super.key,
    required this.callId,
    required this.chatId, // ✅ REQUIRED
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, color: Colors.white, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Incoming Voice Call',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ---------------- ACCEPT BUTTON ----------------
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text('Accept'),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('calls')
                        .doc(callId)
                        .update({'status': 'accepted'});

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoiceCallPage(
                          callId: callId,
                          chatId: chatId,
                          isCaller: false,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),

                // ---------------- REJECT BUTTON ----------------
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.call_end),
                  label: const Text('Reject'),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('calls')
                        .doc(callId)
                        .update({'status': 'ended'});

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
