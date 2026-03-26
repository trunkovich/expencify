import 'package:flutter/material.dart';

import '../core/di/locator.dart';
import '../domain/repositories/auth_repository.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({required this.currentRoute, super.key});

  final String currentRoute;

  void _go(BuildContext context, String route) {
    if (route == currentRoute) {
      Navigator.of(context).pop(); // close drawer
      return;
    }
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Expencify'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Expenses'),
              selected: currentRoute == AppRoutes.expenses,
              onTap: () => _go(context, AppRoutes.expenses),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Reports'),
              selected: currentRoute == AppRoutes.reports,
              onTap: () => _go(context, AppRoutes.reports),
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categories'),
              selected: currentRoute == AppRoutes.categories,
              onTap: () => _go(context, AppRoutes.categories),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Debug'),
              selected: currentRoute == AppRoutes.debug,
              onTap: () => _go(context, AppRoutes.debug),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.of(context).pop(); // close drawer
                await getIt<AuthRepository>().signOut();
                if (!context.mounted) return;
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.auth, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AppRoutes {
  AppRoutes._();

  static const auth = '/auth';
  static const expenses = '/expenses';
  static const reports = '/reports';
  static const categories = '/categories';
  static const debug = '/debug';
}
