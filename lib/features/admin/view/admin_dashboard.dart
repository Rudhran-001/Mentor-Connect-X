import 'package:flutter/material.dart';
import '../viewmodel/admin_viewmodel.dart';
import '../../../data/models/user_model.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = AdminViewModel();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel – Mentor Approvals')),
      body: StreamBuilder<List<UserModel>>(
        stream: vm.unverifiedMentorsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mentors = snapshot.data!;

          if (mentors.isEmpty) {
            return const Center(child: Text('No pending mentor approvals'));
          }

          return ListView.builder(
            itemCount: mentors.length,
            itemBuilder: (context, index) {
              final mentor = mentors[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(mentor.name),
                  subtitle: Text(
                    '${mentor.domain} • ${mentor.email}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await vm.approveMentor(mentor.uid);
                    },
                    child: const Text('Approve'),
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
