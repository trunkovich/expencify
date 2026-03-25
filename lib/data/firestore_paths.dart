/// Firestore collection/document paths for the app.
///
/// Contract:
/// - All user data lives under `users/{uid}/...`
/// - UI must only read/write inside the current user's namespace.
class FirestorePaths {
  FirestorePaths._();

  static String userDoc(String uid) => 'users/$uid';

  static String categoriesCol(String uid) => '${userDoc(uid)}/categories';
  static String categoryDoc(String uid, String categoryId) =>
      '${categoriesCol(uid)}/$categoryId';

  static String expensesCol(String uid) => '${userDoc(uid)}/expenses';
  static String expenseDoc(String uid, String expenseId) =>
      '${expensesCol(uid)}/$expenseId';
}

