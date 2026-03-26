import 'package:expencify/expenses/expense_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseValidator', () {
    test('validateAmount', () {
      expect(ExpenseValidator.validateAmount(null), isNotNull);
      expect(ExpenseValidator.validateAmount(0), isNotNull);
      expect(ExpenseValidator.validateAmount(-1), isNotNull);
      expect(ExpenseValidator.validateAmount(1), isNull);
    });

    test('validateCurrency', () {
      expect(ExpenseValidator.validateCurrency(null), isNotNull);
      expect(ExpenseValidator.validateCurrency(''), isNotNull);
      expect(ExpenseValidator.validateCurrency('US'), isNotNull);
      expect(ExpenseValidator.validateCurrency('USD'), isNull);
      expect(ExpenseValidator.validateCurrency(' usd '), isNull);
    });

    test('validateCategoryId', () {
      expect(ExpenseValidator.validateCategoryId(null), isNotNull);
      expect(ExpenseValidator.validateCategoryId(''), isNotNull);
      expect(ExpenseValidator.validateCategoryId('food'), isNull);
    });
  });
}
