import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_paths.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<int> watchCategoriesCount(String uid) {
    return _firestore
        .collection(FirestorePaths.categoriesCol(uid))
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}

