import 'package:flutter/material.dart';

import 'firebase_error_mapper.dart';

class Snackbars {
  Snackbars._();

  static void showError(BuildContext context, Object error) {
    final message = FirebaseErrorMapper.message(error);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
