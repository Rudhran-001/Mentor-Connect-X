import 'package:flutter/material.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../../data/models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _vm = AuthViewModel();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _domain = TextEditingController();

  bool isSignup = false;
  UserRole role = UserRole.student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor Connect X')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isSignup)
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (isSignup)
              TextField(
                controller: _domain,
                decoration: const InputDecoration(labelText: 'Domain'),
              ),
            if (isSignup)
              DropdownButton<UserRole>(
                value: role,
                items: const [
                  DropdownMenuItem(
                      value: UserRole.student, child: Text('Student')),
                  DropdownMenuItem(
                      value: UserRole.mentor, child: Text('Mentor')),
                ],
                onChanged: (val) => setState(() => role = val!),
              ),
            const SizedBox(height: 20),
            if (_vm.isLoading) const CircularProgressIndicator(),
            if (_vm.error != null)
              Text(_vm.error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () async {
                if (isSignup) {
                  await _vm.signup(
                    email: _email.text,
                    password: _password.text,
                    name: _name.text,
                    role: role,
                    domain: _domain.text,
                  );
                } else {
                  await _vm.login(_email.text, _password.text);
                }
              },
              child: Text(isSignup ? 'Sign Up' : 'Login'),
            ),
            TextButton(
              onPressed: () => setState(() => isSignup = !isSignup),
              child: Text(isSignup
                  ? 'Already have an account? Login'
                  : 'Create new account'),
            )
          ],
        ),
      ),
    );
  }
}
