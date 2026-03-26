import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/categories_repository.dart';
import '../services/expenses_repository.dart';
import '../shared/firebase_error_mapper.dart';
import '../shared/firestore_list_snapshot.dart';

enum ReportsRange { today, week, month }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _categoriesRepo = CategoriesRepository();
  final _expensesRepo = ExpensesRepository();

  ReportsRange _range = ReportsRange.month;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    final now = DateTime.now();
    final (start, endExclusive) = _bounds(now, _range);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<ReportsRange>(
              segments: const [
                ButtonSegment(value: ReportsRange.today, label: Text('Today')),
                ButtonSegment(value: ReportsRange.week, label: Text('Week')),
                ButtonSegment(value: ReportsRange.month, label: Text('Month')),
              ],
              selected: {_range},
              onSelectionChanged: (value) => setState(() => _range = value.single),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<FirestoreListSnapshot<Category>>(
                stream: _categoriesRepo.watchCategories(uid),
                builder: (context, categoriesSnapshot) {
                  if (categoriesSnapshot.hasError) {
                    return Center(
                      child: Text(
                        FirebaseErrorMapper.message(categoriesSnapshot.error!),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (!categoriesSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = categoriesSnapshot.data!.items;
                  final byId = <String, Category>{for (final c in categories) c.id: c};

                  return StreamBuilder<FirestoreListSnapshot<Expense>>(
                    stream: _expensesRepo.watchExpensesInRange(
                      uid,
                      start: start,
                      endExclusive: endExclusive,
                    ),
                    builder: (context, expensesSnapshot) {
                      if (expensesSnapshot.hasError) {
                        return Center(
                          child: Text(
                            FirebaseErrorMapper.message(expensesSnapshot.error!),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      if (!expensesSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final expenses = expensesSnapshot.data!.items;
                      if (expenses.isEmpty) {
                        return const Center(child: Text('No expenses for this period'));
                      }

                      final totals = _sumByCategory(expenses);
                      final rows = totals.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      final totalSum =
                          totals.values.fold<num>(0, (sum, v) => sum + v);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total'),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatAmount(totalSum),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatDate(start)} – ${_formatDate(endExclusive.add(const Duration(days: -1)))}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              itemCount: rows.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final entry = rows[index];
                                final category = byId[entry.key];
                                final title = category == null
                                    ? 'Unknown category'
                                    : '${category.emoji ?? '•'} ${category.name}';
                                return ListTile(
                                  title: Text(title),
                                  trailing: Text(_formatAmount(entry.value)),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  (DateTime start, DateTime endExclusive) _bounds(DateTime now, ReportsRange range) {
    final todayStart = DateTime(now.year, now.month, now.day);
    return switch (range) {
      ReportsRange.today => (todayStart, todayStart.add(const Duration(days: 1))),
      ReportsRange.week => (
          todayStart.subtract(Duration(days: todayStart.weekday - DateTime.monday)),
          todayStart
              .subtract(Duration(days: todayStart.weekday - DateTime.monday))
              .add(const Duration(days: 7)),
        ),
      ReportsRange.month => (
          DateTime(now.year, now.month, 1),
          now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1),
        ),
    };
  }

  Map<String, num> _sumByCategory(List<Expense> expenses) {
    final map = <String, num>{};
    for (final e in expenses) {
      map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
    }
    return map;
  }

  String _formatAmount(num value) {
    final asDouble = value.toDouble();
    final isInt = asDouble % 1 == 0;
    return isInt ? asDouble.toStringAsFixed(0) : asDouble.toStringAsFixed(2);
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}

