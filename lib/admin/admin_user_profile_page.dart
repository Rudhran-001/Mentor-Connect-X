import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserProfilePage extends StatelessWidget {
  final String userId;

  const AdminUserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text('User Details', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = data['role'] ?? 'user';
          final verified = data['verified'] ?? false;
          final profile = data['profile'] ?? {};
          final name = profile['fullName'] ?? 'Unnamed User';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Header Profile Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: (role == 'mentor' ? Colors.indigo : Colors.purple).withOpacity(0.1),
                            child: Text(
                              name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: role == 'mentor' ? Colors.indigo : Colors.purple,
                              ),
                            ),
                          ),
                          if (verified)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.verified, color: Colors.blue, size: 24),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role.toString().toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Dynamic Profile Content
                if (role == 'student') ..._buildInfoCards(_studentProfile(profile)),
                if (role == 'mentor') ..._buildInfoCards(_mentorProfile(profile)),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // Wraps data in a clean, elevated card
  List<Widget> _buildInfoCards(List<Map<String, String?>> items) {
    return [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => Divider(color: Colors.grey[100], height: 1),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[index]['label']!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['value']?.isNotEmpty == true ? items[index]['value']! : '-',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ];
  }

  List<Map<String, String?>> _studentProfile(Map profile) {
    return [
      {'label': 'Education', 'value': profile['education']},
      {'label': 'Location', 'value': profile['location']},
      {'label': 'Bio', 'value': profile['bio']},
    ];
  }

  List<Map<String, String?>> _mentorProfile(Map profile) {
    return [
      {'label': 'Experience', 'value': '${profile['experienceYears']} Years'},
      {'label': 'Domain', 'value': profile['domain']},
      {'label': 'Company', 'value': profile['company']},
      {'label': 'Skills', 'value': (profile['skills'] as List?)?.join(', ')},
      {'label': 'LinkedIn', 'value': profile['linkedin']},
      {'label': 'Bio', 'value': profile['bio']},
    ];
  }
}