import '../../models/expense.dart';
import '../../shared/firestore_list_snapshot.dart';

abstract interface class ExpensesRepository {
  Stream<FirestoreListSnapshot<Expense>> watchExpenses(
    String uid, {
    int limit = 200,
  });

  Stream<FirestoreListSnapshot<Expense>> watchExpensesInRange(
    String uid, {
    required DateTime start,
    required DateTime endExclusive,
    int limit = 2000,
  });

  Future<void> createExpense(String uid, Expense expense);

  Future<void> updateExpense(String uid, Expense expense);

  Future<void> deleteExpense(String uid, String expenseId);
}
