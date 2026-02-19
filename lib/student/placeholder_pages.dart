import 'package:flutter/material.dart';

// 1. Mentor Verse Page -> Redirects to Future Update
class MentorVersePage extends StatelessWidget {
  const MentorVersePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const FutureUpdatePage(title: "Mentor Verse");
  }
}

// 2. AI Tutor Page -> Redirects to Future Update
class AiTutorPage extends StatelessWidget {
  const AiTutorPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const FutureUpdatePage(title: "AI Tutor");
  }
}

// 3. Job Hub Page -> Redirects to Future Update
class JobHubPage extends StatelessWidget {
  const JobHubPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const FutureUpdatePage(title: "Job Hub");
  }
}

// 4. Unlock Page -> Redirects to Future Update
class UnlockPage extends StatelessWidget {
  const UnlockPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const FutureUpdatePage(title: "Unlock");
  }
}

// 5. Ask Page -> Redirects to Future Update
class AskPage extends StatelessWidget {
  const AskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const FutureUpdatePage(title: "Ask");
  }
}

// 6. Jobs Page -> Redirects to Future Update
class JobsPage extends StatelessWidget {
  const JobsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const FutureUpdatePage(title: "Jobs");
  }
}

// 7. Tags Page -> Redirects to Future Update
class TagsPage extends StatelessWidget {
  const TagsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const FutureUpdatePage(title: "Tags");
  }
}

// --- Reusable Future Update Page ---
class FutureUpdatePage extends StatelessWidget {
  final String title;

  const FutureUpdatePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.construction_rounded, size: 60, color: Colors.blue.shade800),
              ),
              const SizedBox(height: 24),
              const Text(
                "Coming Soon",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2642),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We are working hard to bring the $title feature to you. This module will be available in the next major update.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2642),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Go Back", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}