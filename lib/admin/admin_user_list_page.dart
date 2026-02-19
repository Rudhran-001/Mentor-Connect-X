import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_user_profile_page.dart';

class AdminUserListPage extends StatelessWidget {
  final String role; // 'student' or 'mentor'

  const AdminUserListPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final bool isStudent = role == 'student';
    final Color themeColor = isStudent ? Colors.purple : Colors.indigo;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          isStudent ? 'Student Directory' : 'Mentor Directory',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: role)
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
                  Icon(Icons.person_off_rounded, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No $role found', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;
              final bool isVerified = data['verified'] == true;
              final String name = data['name'] ?? 'Unnamed';
              final String email = data['email'] ?? 'No email provided';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminUserProfilePage(userId: doc.id),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Profile Circle with Initial
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: themeColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isVerified
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isVerified
                                      ? Icons.verified_rounded
                                      : Icons.access_time_filled_rounded,
                                  size: 14,
                                  color: isVerified
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isVerified ? 'Verified' : 'Pending',
                                  style: TextStyle(
                                    color: isVerified
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}