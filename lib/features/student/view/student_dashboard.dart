import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
              'Welcome 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Let’s move one step closer to your goal today.',
            ),
            const SizedBox(height: 24),

            // Discover Mentors
            _DashboardCard(
              icon: Icons.search,
              title: 'Discover Mentors',
              subtitle: 'Find mentors by domain and expertise',
              onTap: () {
                // Future: Navigate to mentor discovery
              },
            ),

            // My Sessions
            _DashboardCard(
              icon: Icons.video_call,
              title: 'My Sessions',
              subtitle: 'View upcoming and past sessions',
              onTap: () {
                // Future: Navigate to sessions
              },
            ),

            // Progress
            _DashboardCard(
              icon: Icons.emoji_events,
              title: 'My Progress',
              subtitle: 'Track XP, badges and milestones',
              onTap: () {
                // Future: Navigate to progress
              },
            ),

            // Profile
            _DashboardCard(
              icon: Icons.person,
              title: 'My Profile',
              subtitle: 'View and edit your profile',
              onTap: () {
                // Future: Navigate to profile
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
