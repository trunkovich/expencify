import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/categories_repository.dart';
import '../services/expenses_repository.dart';
import '../shared/firebase_error_mapper.dart';
import '../shared/firestore_list_snapshot.dart';
import 'add_edit_expense_screen.dart';

class ExpensesScreen extends StatelessWidget {
  ExpensesScreen({super.key});

  final _expensesRepo = ExpensesRepository();
  final _categoriesRepo = CategoriesRepository();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AddEditExpenseScreen.newExpense(
              uid: uid,
              key: const ValueKey('new_expense'),
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<FirestoreListSnapshot<Category>>(
        stream: _categoriesRepo.watchCategories(uid),
        builder: (context, categoriesSnapshot) {
          if (categoriesSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(FirebaseErrorMapper.message(categoriesSnapshot.error!)),
              ),
            );
          }
          if (!categoriesSnapshot.hasData) {
            if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Loading… If you are offline and opened this screen for the first time, '
                    'Firestore may have no cached data yet.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          final categoriesData = categoriesSnapshot.data!;
          final categories = categoriesData.items;
          final byId = <String, Category>{
            for (final c in categories) c.id: c,
          };

          return StreamBuilder<FirestoreListSnapshot<Expense>>(
            stream: _expensesRepo.watchExpenses(uid),
            builder: (context, expensesSnapshot) {
              if (expensesSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(FirebaseErrorMapper.message(expensesSnapshot.error!)),
                  ),
                );
              }
              if (!expensesSnapshot.hasData) {
                if (expensesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Loading expenses… If you are offline and have never loaded expenses, '
                        'there may be no cached data yet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }

              final expensesData = expensesSnapshot.data!;
              final expenses = expensesData.items;
              if (expenses.isEmpty) {
                return const Center(child: Text('No expenses yet'));
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: expenses.length,
                      separatorBuilder: (_, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final e = expenses[index];
                        final isPending = expensesData.pendingIds.contains(e.id);
                        final category = byId[e.categoryId];
                        final categoryTitle = category == null
                            ? 'Unknown category'
                            : '${category.emoji ?? '•'} ${category.name}';

                        return ListTile(
                          title: Text('${e.amount} ${e.currency}'),
                          subtitle: Text(categoryTitle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPending) ...[
                                const Icon(Icons.sync, size: 16),
                                const SizedBox(width: 8),
                              ],
                              Text(_formatDate(e.date)),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AddEditExpenseScreen.editExpense(
                                uid: uid,
                                expense: e,
                                key: ValueKey('edit_${e.id}'),
                              ),
                            ),
                          ),
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
    );
  }

  String _formatDate(Timestamp ts) {
    final d = ts.toDate();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}

