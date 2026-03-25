import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';
import '../shared/firestore_list_snapshot.dart';
import 'firestore_paths.dart';

class ExpensesRepository {
  ExpensesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<FirestoreListSnapshot<Expense>> watchExpenses(String uid, {int limit = 200}) {
    return _firestore
        .collection(FirestorePaths.expensesCol(uid))
        .orderBy(Expense.fieldDate, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
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
    });
  }

  Future<void> createExpense(String uid, Expense expense) async {
    await _firestore
        .doc(FirestorePaths.expenseDoc(uid, expense.id))
        .set(expense.toFirestore(), SetOptions(merge: false));
  }

  Future<void> updateExpense(String uid, Expense expense) async {
    await _firestore
        .doc(FirestorePaths.expenseDoc(uid, expense.id))
        .set(expense.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _firestore.doc(FirestorePaths.expenseDoc(uid, expenseId)).delete();
  }
}

