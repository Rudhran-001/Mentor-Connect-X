import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentApprovalPage extends StatefulWidget {
  const StudentApprovalPage({super.key});

  @override
  State<StudentApprovalPage> createState() => _StudentApprovalPageState();
}

class _StudentApprovalPageState extends State<StudentApprovalPage> {
  String? _processingStudentUid;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Approvals'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .where('verified', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load students'));
          }

          final students = snapshot.data!.docs;

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No pending student verifications 🎉',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final doc = students[index];
              final data = doc.data() as Map<String, dynamic>;
              final isProcessing = _processingStudentUid == doc.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(
                    data['name'] ?? 'Unnamed Student',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['email'] ?? ''),
                  trailing: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () => _confirmAndVerify(
                              context: context,
                              studentUid: doc.id,
                              verifierUid: currentUser.uid,
                            ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Verify'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmAndVerify({
    required BuildContext context,
    required String studentUid,
    required String verifierUid,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verify Student'),
        content: const Text(
          'Are you sure you want to verify this student?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _processingStudentUid = studentUid;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentUid)
          .update({
        'verified': true,
        'verifiedBy': verifierUid,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student verified successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingStudentUid = null;
        });
      }
    }
  }
}
