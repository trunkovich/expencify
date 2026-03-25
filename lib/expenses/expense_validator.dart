class ExpenseValidator {
  ExpenseValidator._();

  static String? validateAmount(num? amount) {
    if (amount == null) return 'Amount is required';
    if (amount <= 0) return 'Amount must be > 0';
    return null;
  }

  static String? validateCurrency(String? currency) {
    final c = currency?.trim();
    if (c == null || c.isEmpty) return 'Currency is required';
    if (c.length != 3) return 'Currency must be ISO 4217 (3 letters)';
    return null;
  }

  static String? validateCategoryId(String? categoryId) {
    final id = categoryId?.trim();
    if (id == null || id.isEmpty) return 'Category is required';
    return null;
  }
}

