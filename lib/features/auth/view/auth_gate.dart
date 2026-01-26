import 'package:flutter/material.dart';
import '../viewmodel/auth_gate_viewmodel.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = AuthGateViewModel();

    return FutureBuilder<String>(
      future: viewModel.resolveInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(
            context,
            snapshot.data!,
          );
        });

        return const SizedBox.shrink();
      },
    );
  }
}
