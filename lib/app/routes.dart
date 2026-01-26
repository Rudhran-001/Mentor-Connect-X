import 'package:flutter/material.dart';
import '../features/auth/view/login_page.dart';
import '../features/mentor/view/mentor_pending_approval.dart';
import '../features/student/view/student_dashboard.dart';
import '../features/admin/view/admin_dashboard.dart';
import '../features/mentor/view/mentor_dashboard.dart';

class AppRoutes {
  static const login = '/login';
  static const studentDashboard = '/student';
  static const mentorDashboard = '/mentor';
  static const adminDashboard = '/admin';
  static const mentorPending = '/mentor-pending';


  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginPage(),
    studentDashboard: (_) =>
        const StudentDashboard(),
    mentorDashboard: (_) =>
        const MentorDashboard(),
    adminDashboard: (_) =>
        const AdminDashboard(),
    mentorPending: (_) =>
        const MentorPendingApprovalPage(),

  };
}
