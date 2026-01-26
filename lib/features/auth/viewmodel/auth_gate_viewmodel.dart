import '../../../data/repositories/user_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/services/auth/auth_state_service.dart';
import '../../../app/routes.dart';

class AuthGateViewModel {
  final AuthStateService _authService = AuthStateService();
  final UserRepository _userRepository = UserRepository();

  Future<String> resolveInitialRoute() async {
    final firebaseUser = _authService.currentUser;

    // Not logged in
    if (firebaseUser == null) {
      return AppRoutes.login;
    }

    // Fetch Firestore user
    final user =
        await _userRepository.getUserById(firebaseUser.uid);

    // User doc missing → force logout later
    if (user == null) {
      return AppRoutes.login;
    }

    // Role-based routing
    switch (user.role) {
      case UserRole.student:
        return AppRoutes.studentDashboard;

      case UserRole.mentor:
        if (!user.verified) {
          return AppRoutes.mentorPending; // later: pending approval screen
        }
        return AppRoutes.mentorDashboard;

      case UserRole.admin:
        return AppRoutes.adminDashboard;
    }
  }
}
