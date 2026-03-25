import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../categories/categories_screen.dart';
import '../data/categories_repository.dart';
import '../data/firestore_service.dart';
import '../expenses/expenses_screen.dart';
import '../shared/firebase_error_mapper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;
    final service = FirestoreService();
    final categoriesRepo = CategoriesRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Center(
        child: uid == null
            ? const Text('No user (unexpected)')
            : StreamBuilder<int>(
                stream: service.watchCategoriesCount(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(FirebaseErrorMapper.message(snapshot.error!)),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final count = snapshot.data!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('User: ${email ?? uid}'),
                      const SizedBox(height: 8),
                      Text('Categories: $count'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => categoriesRepo.ensureDefaultPresets(uid),
                        child: const Text('Create default presets (once)'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CategoriesScreen(),
                          ),
                        ),
                        child: const Text('Manage categories'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ExpensesScreen(),
                          ),
                        ),
                        child: const Text('Manage expenses'),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
