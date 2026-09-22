import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/create_seller_params.dart';
import '../bloc/sellers_bloc.dart';
import '../bloc/sellers_event.dart';

/// Modal bottom sheet to register a new cashier seller with +992 validation and commission slider.
class CreateSellerSheet extends StatefulWidget {
  const CreateSellerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SellersBloc>(),
        child: const CreateSellerSheet(),
      ),
    );
  }

  @override
  State<CreateSellerSheet> createState() => _CreateSellerSheetState();
}

class _CreateSellerSheetState extends State<CreateSellerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+992');
  final _passwordController = TextEditingController();

  double _commissionRate = 5.0;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Введите номер телефона продавца';
    }
    final cleanPhone = val.replaceAll(RegExp(r'\s+'), '');
    if (!cleanPhone.startsWith('+992')) {
      return 'Номер должен начинаться с +992';
    }
    if (cleanPhone.length != 13) {
      return 'Номер должен содержать 9 цифр после +992';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    final params = CreateSellerParams(
      name: _nameController.text.trim(),
      phone: cleanPhone,
      password: _passwordController.text,
      commissionRate: Decimal.parse(_commissionRate.toStringAsFixed(2)),
    );

    context.read<SellersBloc>().add(SellerCreateSubmitted(params));
    Navigator.of(context).pop();
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
              // Handle
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
                      color: Colors.blue.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_add_rounded, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Новый продавец',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'ФИО сотрудника *',
                  hintText: 'Например: Алишери Саид',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Введите имя сотрудника';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone with +992
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Номер телефона (+992...) *',
                  hintText: '+992900000000',
                  prefixIcon: const Icon(Icons.phone_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Пароль для входа *',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Задайте пароль сотрудника';
                  }
                  if (val.length < 6) {
                    return 'Пароль должен содержать минимум 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Starting Commission Rate Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Стартовая комиссия:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '${_commissionRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _commissionRate,
                min: 0.0,
                max: 100.0,
                divisions: 200,
                label: '${_commissionRate.toStringAsFixed(1)}%',
                onChanged: (val) => setState(() => _commissionRate = val),
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Зарегистрировать продавца',
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
