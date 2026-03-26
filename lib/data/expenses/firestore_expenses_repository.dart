import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/expenses_repository.dart';
import '../../models/expense.dart';
import '../../services/firestore_paths.dart';
import '../../shared/firestore_list_snapshot.dart';

class FirestoreExpensesRepository implements ExpensesRepository {
  FirestoreExpensesRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<FirestoreListSnapshot<Expense>> watchExpenses(String uid, {int limit = 200}) {
    return _firestore
        .collection(FirestorePaths.expensesCol(uid))
        .orderBy(Expense.fieldDate, descending: true)
        .limit(limit)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<FirestoreListSnapshot<Expense>> watchExpensesInRange(
    String uid, {
    required DateTime start,
    required DateTime endExclusive,
    int limit = 2000,
  }) {
    final startTs = Timestamp.fromDate(start);
    final endTs = Timestamp.fromDate(endExclusive);
    return _firestore
        .collection(FirestorePaths.expensesCol(uid))
        .where(Expense.fieldDate, isGreaterThanOrEqualTo: startTs)
        .where(Expense.fieldDate, isLessThan: endTs)
        .orderBy(Expense.fieldDate, descending: true)
        .limit(limit)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Future<void> createExpense(String uid, Expense expense) {
    return _firestore
        .doc(FirestorePaths.expenseDoc(uid, expense.id))
        .set(expense.toFirestore(), SetOptions(merge: false));
  }

  @override
  Future<void> updateExpense(String uid, Expense expense) {
    return _firestore
        .doc(FirestorePaths.expenseDoc(uid, expense.id))
        .set(expense.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteExpense(String uid, String expenseId) {
    return _firestore.doc(FirestorePaths.expenseDoc(uid, expenseId)).delete();
  }

  FirestoreListSnapshot<Expense> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final pendingIds = snapshot.docs
        .where((d) => d.metadata.hasPendingWrites)
        .map((d) => d.id)
        .toSet();
    final items = snapshot.docs
        .map((doc) => Expense.fromFirestore(id: doc.id, data: doc.data()))
        .toList(growable: false);
    return FirestoreListSnapshot<Expense>(
      items: items,
      isFromCache: snapshot.metadata.isFromCache,
      hasPendingWrites: snapshot.metadata.hasPendingWrites,
      pendingIds: pendingIds,
    );
  }
}

