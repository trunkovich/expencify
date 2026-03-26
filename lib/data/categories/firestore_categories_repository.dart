import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/categories_repository.dart';
import '../../models/category.dart';
import '../../services/category_presets.dart';
import '../../services/firestore_paths.dart';
import '../../shared/firestore_list_snapshot.dart';

class FirestoreCategoriesRepository implements CategoriesRepository {
  FirestoreCategoriesRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<FirestoreListSnapshot<Category>> watchCategories(String uid) {
    return _firestore
        .collection(FirestorePaths.categoriesCol(uid))
        .orderBy(Category.fieldSortOrder)
        .snapshots()
        .map((snapshot) {
          final pendingIds = snapshot.docs
              .where((d) => d.metadata.hasPendingWrites)
              .map((d) => d.id)
              .toSet();
          final items = snapshot.docs
              .map(
                (doc) => Category.fromFirestore(id: doc.id, data: doc.data()),
              )
              .toList(growable: false);
          return FirestoreListSnapshot<Category>(
            items: items,
            isFromCache: snapshot.metadata.isFromCache,
            hasPendingWrites: snapshot.metadata.hasPendingWrites,
            pendingIds: pendingIds,
          );
        });
  }

  @override
  Future<void> createOrUpdateCategory(String uid, Category category) async {
    await _firestore
        .doc(FirestorePaths.categoryDoc(uid, category.id))
        .set(category.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteCategory(String uid, String categoryId) async {
    await _firestore.doc(FirestorePaths.categoryDoc(uid, categoryId)).delete();
  }

  @override
  Future<bool> ensureDefaultPresets(String uid) async {
    final existing = await _firestore
        .collection(FirestorePaths.categoriesCol(uid))
        .limit(1)
        .get();
    if (existing.size > 0) return false;

    final now = Timestamp.now();
    final batch = _firestore.batch();
    for (final category in CategoryPresets.build(now: now)) {
      final ref = _firestore.doc(FirestorePaths.categoryDoc(uid, category.id));
      batch.set(ref, category.toFirestore(), SetOptions(merge: true));
    }
    await batch.commit();
    return true;
  }
}
