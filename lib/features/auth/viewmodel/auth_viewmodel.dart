import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool isLoading = false;
  String? error;

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authRepository.login(
        email: email,
        password: password,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String domain,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authRepository.signup(
        email: email,
        password: password,
        name: name,
        role: role,
        domain: domain,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
