import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateChatPage extends StatefulWidget {
  const CreateChatPage({super.key});

  @override
  State<CreateChatPage> createState() => _CreateChatPageState();
}

class _CreateChatPageState extends State<CreateChatPage> {
  String? _selectedStudentId;
  bool _creating = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'New Conversation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Header / Instruction
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'Select a student to start mentoring',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Student List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .where('verified', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No verified students available',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                final students = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: students.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = students[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isSelected = _selectedStudentId == doc.id;
                    final name = data['name'] ?? 'Unnamed Student';
                    final email = data['email'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStudentId = doc.id;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isSelected
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.grey.shade100,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: isSelected ? Colors.blue : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.blue.shade900
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue.shade700
                                          : Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Checkmark Icon
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.blue),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedStudentId == null || _creating
                      ? null
                      : () => _createChat(currentUser.uid),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _creating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Start Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createChat(String creatorUid) async {
    setState(() => _creating = true);

    try {
      final mentorId = creatorUid;

      // Create the chat document
      await _firestore.collection('chats').add({
        'mentorId': mentorId,
        'studentId': _selectedStudentId,
        'createdBy': creatorUid,
        'createdAt': FieldValue.serverTimestamp(),
        'active': true,
        'lastMessage': null,
        'lastMessageAt': null,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chat session created successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create chat: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }
}