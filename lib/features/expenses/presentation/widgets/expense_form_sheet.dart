import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/create_expense_params.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';

/// Modal bottom sheet to create a new operational business expense.
class ExpenseFormSheet extends StatefulWidget {
  const ExpenseFormSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ExpensesBloc>(),
        child: const ExpenseFormSheet(),
      ),
    );
  }

  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();

  String _selectedCategory = 'utilities';
  DateTime _selectedDate = DateTime.now();

  static const List<Map<String, String>> _categories = [
    {'key': 'utilities', 'label': 'Коммуналка'},
    {'key': 'rent', 'label': 'Аренда'},
    {'key': 'salary', 'label': 'Зарплата'},
    {'key': 'logistics', 'label': 'Логистика'},
    {'key': 'marketing', 'label': 'Реклама'},
    {'key': 'supplies', 'label': 'Расходники'},
    {'key': 'other', 'label': 'Прочее'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final parsedAmount = Decimal.tryParse(_amountController.text.trim());
    if (parsedAmount == null || parsedAmount <= Decimal.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректную сумму расхода больше 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final params = CreateExpenseParams(
      amount: parsedAmount,
      category: _selectedCategory,
      comment: _commentController.text.trim(),
      expenseDate: _selectedDate,
    );

    context.read<ExpensesBloc>().add(ExpenseCreateSubmitted(params));
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Расход на ${parsedAmount.toStringAsFixed(2)} TJS сохранён'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Новый расход',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Сумма расхода (TJS) *',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Введите сумму расхода';
                  }
                  final d = Decimal.tryParse(val.trim());
                  if (d == null || d <= Decimal.zero) {
                    return 'Сумма должна быть больше 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector Chips
              const Text(
                'Категория расхода',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final isSelected = _selectedCategory == c['key'];
                  return ChoiceChip(
                    label: Text(c['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = c['key']!);
                      }
                    },
                    selectedColor: theme.colorScheme.primary.withAlpha(40),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Date Picker Field
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Дата расхода',
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Comment Input
              TextFormField(
                controller: _commentController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Комментарий / Назначение платежа',
                  hintText: 'Например: оплата за электричество за сентябрь',
                  prefixIcon: const Icon(Icons.comment_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Записать расход',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
