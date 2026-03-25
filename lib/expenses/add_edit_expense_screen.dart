import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/categories_repository.dart';
import '../services/expenses_repository.dart';
import '../shared/firebase_error_mapper.dart';
import '../shared/firestore_list_snapshot.dart';
import '../shared/snackbars.dart';
import 'expense_validator.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen._({
    required this.uid,
    this.expense,
    required this.title,
    super.key,
  });

  factory AddEditExpenseScreen.newExpense({required String uid, Key? key}) {
    return AddEditExpenseScreen._(
      uid: uid,
      expense: null,
      title: 'Add expense',
      key: key,
    );
  }

  factory AddEditExpenseScreen.editExpense({
    required String uid,
    required Expense expense,
    Key? key,
  }) {
    return AddEditExpenseScreen._(
      uid: uid,
      expense: expense,
      title: 'Edit expense',
      key: key,
    );
  }

  final String uid;
  final Expense? expense;
  final String title;

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _expensesRepo = ExpensesRepository();
  final _categoriesRepo = CategoriesRepository();

  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  final _noteController = TextEditingController();

  String? _categoryId;
  DateTime _date = DateTime.now();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    if (e != null) {
      _amountController.text = e.amount.toString();
      _currencyController.text = e.currency;
      _noteController.text = e.note ?? '';
      _categoryId = e.categoryId;
      _date = e.date.toDate();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  num? _parseAmount() {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    return num.tryParse(raw);
  }

  Future<void> _save() async {
    final amount = _parseAmount();
    final currency = _currencyController.text.trim().toUpperCase();
    final categoryId = _categoryId;

    final amountError = ExpenseValidator.validateAmount(amount);
    final currencyError = ExpenseValidator.validateCurrency(currency);
    final categoryError = ExpenseValidator.validateCategoryId(categoryId);
    final firstError = amountError ?? currencyError ?? categoryError;
    if (firstError != null) {
      Snackbars.showMessage(context, firstError);
      return;
    }

    try {
      final now = Timestamp.now();
      final existing = widget.expense;
      final id = existing?.id ?? FirebaseFirestore.instance.collection('tmp').doc().id;

      final expense = Expense(
        id: id,
        amount: amount!,
        currency: currency,
        date: Timestamp.fromDate(_date),
        categoryId: categoryId!,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      final Future<void> write = existing == null
          ? _expensesRepo.createExpense(widget.uid, expense)
          : _expensesRepo.updateExpense(widget.uid, expense);

      unawaited(
        write.catchError((Object e) {
          if (!mounted) return;
          Snackbars.showError(context, e);
        }),
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      Snackbars.showError(context, e);
    }
  }

  Future<void> _delete() async {
    final e = widget.expense;
    if (e == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final delete = _expensesRepo.deleteExpense(widget.uid, e.id);
      unawaited(
        delete.catchError((Object err) {
          if (!mounted) return;
          Snackbars.showError(context, err);
        }),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (err) {
      if (!mounted) return;
      Snackbars.showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.expense != null)
            IconButton(
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: StreamBuilder<FirestoreListSnapshot<Category>>(
          stream: _categoriesRepo.watchCategories(widget.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(FirebaseErrorMapper.message(snapshot.error!)),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            final categories = data.items;
            if (categories.isEmpty) {
              return const Center(child: Text('Create a category first'));
            }

            final hasSelected = _categoryId != null &&
                categories.any((c) => c.id == _categoryId);
            if (_categoryId != null && !hasSelected) {
              // The expense points to a deleted category; require user to re-select.
              _categoryId = null;
            }
            _categoryId ??= categories.first.id;

            return ListView(
              children: [
                TextField(
                  controller: _amountController,
                  enabled: !_busy,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _currencyController,
                  enabled: !_busy,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Currency (ISO 4217)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _categoryId,
                      isExpanded: true,
                      items: [
                        for (final c in categories)
                          DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.emoji ?? '•'} ${c.name}'),
                          ),
                      ],
                      onChanged: _busy ? null : (v) => setState(() => _categoryId = v),
                    ),
                  ),
                ),
                if (widget.expense != null && widget.expense!.categoryId != _categoryId)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Original category was deleted. Please select a new category.',
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _busy ? null : _pickDate,
                  child: Text('Date: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  enabled: !_busy,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Text(widget.expense == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

