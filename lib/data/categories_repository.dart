import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_paths.dart';
import 'models/category.dart';
import 'category_presets.dart';

class CategoriesRepository {
  CategoriesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Category>> watchCategories(String uid) {
    return _firestore
        .collection(FirestorePaths.categoriesCol(uid))
        .orderBy(Category.fieldSortOrder)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Category.fromFirestore(
                    id: doc.id,
                    data: doc.data(),
                  ))
              .toList(growable: false),
        );
  }

  Future<void> createOrUpdateCategory(String uid, Category category) async {
    await _firestore
        .doc(FirestorePaths.categoryDoc(uid, category.id))
        .set(category.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteCategory(String uid, String categoryId) async {
    await _firestore.doc(FirestorePaths.categoryDoc(uid, categoryId)).delete();
  }

  Future<bool> ensureDefaultPresets(String uid) async {
    final existing = await _firestore
        .collection(FirestorePaths.categoriesCol(uid))
        .limit(1)
        .get();
    if (existing.size > 0) {
      return false;
    }

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

