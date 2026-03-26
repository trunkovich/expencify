import 'package:cloud_firestore/cloud_firestore.dart';

/// `users/{uid}/categories/{categoryId}`
///
/// Fields:
/// - name: String
/// - emoji: String? (optional)
/// - sortOrder: int
/// - createdAt: Timestamp
/// - updatedAt: Timestamp
class Category {
  const Category({
    required this.id,
    required this.name,
    this.emoji,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? emoji;
  final int sortOrder;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  static const fieldName = 'name';
  static const fieldEmoji = 'emoji';
  static const fieldSortOrder = 'sortOrder';
  static const fieldCreatedAt = 'createdAt';
  static const fieldUpdatedAt = 'updatedAt';

  Map<String, Object?> toFirestore() {
    return <String, Object?>{
      fieldName: name,
      fieldEmoji: emoji,
      fieldSortOrder: sortOrder,
      fieldCreatedAt: createdAt,
      fieldUpdatedAt: updatedAt,
    };
  }

  factory Category.fromFirestore({
    required String id,
    required Map<String, Object?> data,
  }) {
    final name = data[fieldName];
    final emoji = data[fieldEmoji];
    final sortOrder = data[fieldSortOrder];
    final createdAt = data[fieldCreatedAt];
    final updatedAt = data[fieldUpdatedAt];

    if (name is! String) {
      throw FormatException('Category.name must be a String', data);
    }
    if (emoji != null && emoji is! String) {
      throw FormatException('Category.emoji must be a String?', data);
    }
    if (sortOrder is! int) {
      throw FormatException('Category.sortOrder must be an int', data);
    }
    if (createdAt is! Timestamp) {
      throw FormatException('Category.createdAt must be a Timestamp', data);
    }
    if (updatedAt is! Timestamp) {
      throw FormatException('Category.updatedAt must be a Timestamp', data);
    }

    return Category(
      id: id,
      name: name,
      emoji: emoji as String?,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
