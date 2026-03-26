import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthRepository {
  Stream<User?> authStateChanges();

  User? currentUser();

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();
}
