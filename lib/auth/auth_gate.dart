import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../expenses/expenses_screen.dart';
import '../login/login_screen.dart';
import '../core/di/locator.dart';
import '../domain/repositories/auth_repository.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: getIt<AuthRepository>().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return ExpensesScreen();
      },
    );
  }
}
