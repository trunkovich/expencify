import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/auth/firebase_auth_repository.dart';
import '../../data/categories/firestore_categories_repository.dart';
import '../../data/expenses/firestore_expenses_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/categories_repository.dart';
import '../../domain/repositories/expenses_repository.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<FirebaseFirestore>()) return;

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(
      auth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );
  getIt.registerLazySingleton<CategoriesRepository>(
    () => FirestoreCategoriesRepository(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<ExpensesRepository>(
    () => FirestoreExpensesRepository(firestore: getIt<FirebaseFirestore>()),
  );
}
