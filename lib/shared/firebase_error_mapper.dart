import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static String message(Object error) {
    if (error is FirebaseAuthException) {
      return _authMessage(error);
    }

    if (error is FirebaseException) {
      return _firebaseMessage(error);
    }

    return 'Unexpected error: $error';
  }

  static String _firebaseMessage(FirebaseException e) {
    // Firestore uses FirebaseException with plugin "cloud_firestore".
    final code = e.code;
    return switch (code) {
      'permission-denied' => 'Permission denied.',
      'unavailable' => 'Service unavailable. Check your internet connection.',
      'deadline-exceeded' => 'Request timed out. Try again.',
      'not-found' => 'Not found.',
      _ => 'Firebase error ($code): ${e.message ?? ''}'.trim(),
    };
  }

  static String _authMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'Invalid email format.',
      'user-disabled' => 'This user is disabled.',
      'user-not-found' => 'User not found.',
      'wrong-password' => 'Wrong password.',
      'email-already-in-use' => 'Email is already in use.',
      'weak-password' => 'Password is too weak.',
      'operation-not-allowed' => 'This sign-in method is disabled in Firebase Console.',
      'network-request-failed' => 'Network error. Check your internet connection.',
      _ => 'Auth error (${e.code}): ${e.message ?? ''}'.trim(),
    };
  }
}
