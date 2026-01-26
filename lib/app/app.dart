import 'package:flutter/material.dart';
import '../features/auth/view/auth_gate.dart';
import 'routes.dart';

class MentorConnectXApp extends StatelessWidget {
  const MentorConnectXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mentor Connect X',
      routes: AppRoutes.routes,
      home: const AuthGate(),
    );
  }
}
