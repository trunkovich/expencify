import 'package:cloud_firestore/cloud_firestore.dart';

/// `users/{uid}/expenses/{expenseId}`
///
/// Fields:
/// - amount: num (stored as number)
/// - currency: String (ISO 4217, e.g. "USD")
/// - date: Timestamp (the expense date/time)
/// - categoryId: String
/// - note: String? (optional)
/// - createdAt: Timestamp
/// - updatedAt: Timestamp
class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.currency,
    required this.date,
    required this.categoryId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final num amount;
  final String currency;
  final Timestamp date;
  final String categoryId;
  final String? note;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  static const fieldAmount = 'amount';
  static const fieldCurrency = 'currency';
  static const fieldDate = 'date';
  static const fieldCategoryId = 'categoryId';
  static const fieldNote = 'note';
  static const fieldCreatedAt = 'createdAt';
  static const fieldUpdatedAt = 'updatedAt';

  Map<String, Object?> toFirestore() {
    return <String, Object?>{
      fieldAmount: amount,
      fieldCurrency: currency,
      fieldDate: date,
      fieldCategoryId: categoryId,
      fieldNote: note,
      fieldCreatedAt: createdAt,
      fieldUpdatedAt: updatedAt,
    };
  }

  factory Expense.fromFirestore({
    required String id,
    required Map<String, Object?> data,
  }) {
    final amount = data[fieldAmount];
    final currency = data[fieldCurrency];
    final date = data[fieldDate];
    final categoryId = data[fieldCategoryId];
    final note = data[fieldNote];
    final createdAt = data[fieldCreatedAt];
    final updatedAt = data[fieldUpdatedAt];

    if (amount is! num) {
      throw FormatException('Expense.amount must be a num', data);
    }
    if (currency is! String) {
      throw FormatException('Expense.currency must be a String', data);
    }
    if (date is! Timestamp) {
      throw FormatException('Expense.date must be a Timestamp', data);
    }
    if (categoryId is! String) {
      throw FormatException('Expense.categoryId must be a String', data);
    }
    if (note != null && note is! String) {
      throw FormatException('Expense.note must be a String?', data);
    }
    if (createdAt is! Timestamp) {
      throw FormatException('Expense.createdAt must be a Timestamp', data);
    }
    if (updatedAt is! Timestamp) {
      throw FormatException('Expense.updatedAt must be a Timestamp', data);
    }

    return Expense(
      id: id,
      amount: amount,
      currency: currency,
      date: date,
      categoryId: categoryId,
      note: note as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

