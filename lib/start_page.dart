import 'package:flutter/material.dart';
import 'student/student_home.dart';
import 'mentor/mentor_home.dart';
import 'admin/admin_home.dart';

class StartPage extends StatefulWidget {
  final String role; // 'student' | 'mentor' | 'admin'

  const StartPage({super.key, required this.role});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardData> _pages = const [
    _OnboardData(
      icon: Icons.public,
      title: 'Explore MentorVerse',
      subtitle:
          'Navigate through domain-themed worlds: Medical Island, Tech Tower, Legal Fortress & more!',
    ),
    _OnboardData(
      icon: Icons.security,
      title: '100% Privacy Protected',
      subtitle:
          'No contact info shared. All interactions happen securely in-app with end-to-end encryption.',
    ),
    _OnboardData(
      icon: Icons.smart_toy,
      title: 'AI-Powered Growth',
      subtitle:
          'Get personalized career roadmaps, session summaries, and smart mentor matching.',
    ),
    _OnboardData(
      icon: Icons.emoji_events,
      title: 'Gamified Learning',
      subtitle:
          'Earn XP, badges, certifications and climb the leaderboard as you grow!',
    ),
  ];

  void _goNext() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Widget destination;

    if (widget.role == 'admin') {
      destination = const AdminHomePage();
    } else if (widget.role == 'mentor') {
      destination = const MentorHomePage();
    } else {
      destination = const StudentHomePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardPage(data: _pages[index]);
                },
              ),
            ),

            // Dots + Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text('Skip'),
                  ),

                  const Spacer(),

                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentIndex ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentIndex
                              ? const Color(0xFF5AC8FA)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    height: 44,
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2A43),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _goNext,
                      child: Text(
                        _currentIndex == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;

  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 56,
              color: const Color(0xFF0A2A43),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
