import 'package:flutter/material.dart';
import 'auth/auth_page.dart';

class AppStartPage extends StatelessWidget {
  const AppStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A2A43),
              Color(0xFF0F3D5E),
              Color(0xFF0A2A43),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon Container
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF5AC8FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.rocket_launch,
                  size: 42,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            const Text(
              'MentorConnectX',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Your Career Acceleration Ecosystem',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 48),

            // Get Started Button (acts as splash continue)
            SizedBox(
              width: 160,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5AC8FA),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AuthPage(),
                    ),
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
