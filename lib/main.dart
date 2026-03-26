import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/di/locator.dart';
import 'firebase_options.dart';
import 'auth/auth_gate.dart';
import 'categories/categories_screen.dart';
import 'debug/debug_screen.dart';
import 'expenses/expenses_screen.dart';
import 'navigation/app_drawer.dart';
import 'reports/reports_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expencify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      routes: {
        AppRoutes.auth: (_) => const AuthGate(),
        AppRoutes.expenses: (_) => ExpensesScreen(),
        AppRoutes.reports: (_) => const ReportsScreen(),
        AppRoutes.categories: (_) => const CategoriesScreen(),
        AppRoutes.debug: (_) => const DebugScreen(),
      },
      home: const AuthGate(),
    );
  }
}
