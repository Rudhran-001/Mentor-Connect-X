import 'package:flutter/material.dart';

class MentorDashboard extends StatelessWidget {
  const MentorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Mentor 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your sessions and guide students effectively.',
            ),
            const SizedBox(height: 24),

            // Session Requests
            _DashboardCard(
              icon: Icons.inbox,
              title: 'Session Requests',
              subtitle: 'Approve or reject mentorship requests',
              onTap: () {
                // Future: Navigate to requests
              },
            ),

            // Active Sessions
            _DashboardCard(
              icon: Icons.video_camera_front,
              title: 'Active Sessions',
              subtitle: 'Ongoing and upcoming sessions',
              onTap: () {
                // Future: Navigate to active sessions
              },
            ),

            // Availability
            _DashboardCard(
              icon: Icons.schedule,
              title: 'Availability',
              subtitle: 'Manage your available time slots',
              onTap: () {
                // Future: Navigate to availability
              },
            ),

            // Earnings
            _DashboardCard(
              icon: Icons.account_balance_wallet,
              title: 'Earnings',
              subtitle: 'Track your earnings and payouts',
              onTap: () {
                // Future: Navigate to earnings
              },
            ),

            // Profile
            _DashboardCard(
              icon: Icons.person,
              title: 'My Profile',
              subtitle: 'View and update your mentor profile',
              onTap: () {
                // Future: Navigate to mentor profile
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
