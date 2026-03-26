import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../categories/categories_screen.dart';
import '../expenses/expenses_screen.dart';
import '../reports/reports_screen.dart';
import '../services/categories_repository.dart';
import '../services/firestore_paths.dart';
import '../services/firestore_service.dart';
import '../shared/firebase_error_mapper.dart';
import '../shared/snackbars.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = FirestoreService();
  final _categoriesRepo = CategoriesRepository();
  final _firestore = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _seedExpenses({int count = 40}) async {
    await _runTest('seed $count expenses', () async {
      final categoriesSnap = await _firestore
          .collection(FirestorePaths.categoriesCol(_uid))
          .limit(200)
          .get();
      final categoryIds = categoriesSnap.docs.map((d) => d.id).toList(growable: false);
      if (categoryIds.isEmpty) {
        throw StateError('No categories found. Create presets first.');
      }

      final now = DateTime.now();
      final batch = _firestore.batch();

      for (var i = 0; i < count; i++) {
        final createdAt = Timestamp.now();
        final daysAgo = i % 35; // spread over ~1 month
        final date = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: daysAgo))
            .add(Duration(hours: (i * 3) % 24, minutes: (i * 7) % 60));

        final categoryId = categoryIds[i % categoryIds.length];
        final amount = ((i * 137) % 4900) / 100 + 1; // 1.00..50.00-ish
        final id = _firestore.collection('tmp').doc().id;

        final ref = _firestore.doc(FirestorePaths.expenseDoc(_uid, id));
        batch.set(ref, <String, Object?>{
          'amount': amount,
          'currency': 'USD',
          'date': Timestamp.fromDate(date),
          'categoryId': categoryId,
          'note': i % 4 == 0 ? 'seed #$i' : null,
          'createdAt': createdAt,
          'updatedAt': createdAt,
        });
      }

      await batch.commit();
    });
  }

  Future<void> _runTest(String name, Future<void> Function() action) async {
    try {
      await action();
      if (!mounted) return;
      Snackbars.showMessage(context, 'PASS: $name');
    } catch (e) {
      if (!mounted) return;
      Snackbars.showMessage(context, 'FAIL: $name → ${FirebaseErrorMapper.message(e)}');
    }
  }

  Future<void> _testWriteOtherUserCategory() {
    return _runTest('write category to other uid (should FAIL)', () async {
      final now = Timestamp.now();
      await _firestore.doc('users/other-user/categories/rules_probe').set(<String, Object?>{
        'name': 'Should fail',
        'emoji': '🚫',
        'sortOrder': 0,
        'createdAt': now,
        'updatedAt': now,
      });
    });
  }

  Future<void> _testInvalidCategorySchema() {
    return _runTest('invalid category schema (should FAIL)', () async {
      final now = Timestamp.now();
      await _firestore
          .doc('users/$_uid/categories/rules_probe_invalid_schema')
          .set(<String, Object?>{
        'name': 'Bad category',
        'sortOrder': 'not-an-int',
        'createdAt': now,
        'updatedAt': now,
      });
    });
  }

  Future<void> _testInvalidExpenseSchema() {
    return _runTest('invalid expense schema (should FAIL)', () async {
      final now = Timestamp.now();
      await _firestore
          .doc('users/$_uid/expenses/rules_probe_invalid_schema')
          .set(<String, Object?>{
        'amount': 'abc',
        'currency': 'US',
        'date': now,
        'categoryId': 'some-category',
        'createdAt': now,
        'updatedAt': now,
      });
    });
  }

  Future<void> _testExtraFieldDenied() {
    return _runTest('extra field denied (should FAIL)', () async {
      final now = Timestamp.now();
      await _firestore
          .doc('users/$_uid/categories/rules_probe_extra_field')
          .set(<String, Object?>{
        'name': 'Extra field',
        'sortOrder': 1,
        'createdAt': now,
        'updatedAt': now,
        'hacker': true,
      });
    });
  }

  Future<void> _testValidCategoryRoundtrip() {
    return _runTest('valid category write/delete (should PASS)', () async {
      final now = Timestamp.now();
      final id = 'rules_probe_ok_${now.millisecondsSinceEpoch}';
      final ref = _firestore.doc('users/$_uid/categories/$id');
      await ref.set(<String, Object?>{
        'name': 'Rules OK',
        'emoji': '✅',
        'sortOrder': 999999,
        'createdAt': now,
        'updatedAt': now,
      });
      await ref.delete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;

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
                stream: _service.watchCategoriesCount(uid),
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
                        onPressed: () => _categoriesRepo.ensureDefaultPresets(uid),
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
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ReportsScreen(),
                          ),
                        ),
                        child: const Text('Reports'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => _seedExpenses(count: 40),
                        child: const Text('Generate sample expenses (40)'),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: ExpansionTile(
                          title: const Text('Rules test cases'),
                          subtitle: const Text('Run with internet ON (server rules)'),
                          childrenPadding: const EdgeInsets.all(12),
                          children: [
                            FilledButton.tonal(
                              onPressed: _testValidCategoryRoundtrip,
                              child: const Text('PASS: valid category write/delete'),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.tonal(
                              onPressed: _testWriteOtherUserCategory,
                              child: const Text('FAIL: write category to other uid'),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.tonal(
                              onPressed: _testInvalidCategorySchema,
                              child: const Text('FAIL: invalid category schema'),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.tonal(
                              onPressed: _testInvalidExpenseSchema,
                              child: const Text('FAIL: invalid expense schema'),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.tonal(
                              onPressed: _testExtraFieldDenied,
                              child: const Text('FAIL: extra field denied'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
