import '../../models/category.dart';
import '../../shared/firestore_list_snapshot.dart';

abstract interface class CategoriesRepository {
  Stream<FirestoreListSnapshot<Category>> watchCategories(String uid);

  Future<void> createOrUpdateCategory(String uid, Category category);

  Future<void> deleteCategory(String uid, String categoryId);

  Future<bool> ensureDefaultPresets(String uid);
}

