import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/seller_entity.dart';
import '../bloc/sellers_bloc.dart';
import '../bloc/sellers_event.dart';

/// Modal bottom sheet to update a seller's commission rate (0% - 100%).
class UpdateCommissionSheet extends StatefulWidget {
  final SellerEntity seller;

  const UpdateCommissionSheet({super.key, required this.seller});

  static Future<void> show(BuildContext context, SellerEntity seller) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SellersBloc>(),
        child: UpdateCommissionSheet(seller: seller),
      ),
    );
  }

  @override
  State<UpdateCommissionSheet> createState() => _UpdateCommissionSheetState();
}

class _UpdateCommissionSheetState extends State<UpdateCommissionSheet> {
  late double _commissionSliderValue;
  late TextEditingController _commissionController;

  @override
  void initState() {
    super.initState();
    final initialRate = widget.seller.commissionRate.toDouble();
    _commissionSliderValue = initialRate.clamp(0.0, 100.0);
    _commissionController = TextEditingController(
      text: _commissionSliderValue.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _commissionController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _commissionSliderValue = value;
      _commissionController.text = value.toStringAsFixed(2);
    });
  }

  void _onTextChanged(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0.0 && parsed <= 100.0) {
      setState(() {
        _commissionSliderValue = parsed;
      });
    }
  }

  void _submit() {
    final parsedRate = Decimal.tryParse(_commissionController.text.trim());
    if (parsedRate == null ||
        parsedRate < Decimal.zero ||
        parsedRate > Decimal.fromInt(100)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ставка комиссии должна быть в диапазоне от 0% до 100%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<SellersBloc>().add(
          SellerCommissionUpdateSubmitted(
            sellerId: widget.seller.id,
            newCommissionRate: parsedRate,
          ),
        );
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
                  color: theme.colorScheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.percent_rounded, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ставка комиссии продавца',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.seller.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Input field with percentage suffix
          TextFormField(
            controller: _commissionController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              labelText: 'Комиссия от суммы чека',
              suffixText: '%',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
          ),
          const SizedBox(height: 16),

          // Slider (0% - 100%)
          Row(
            children: [
              const Text('0%', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Expanded(
                child: Slider(
                  value: _commissionSliderValue,
                  min: 0.0,
                  max: 100.0,
                  divisions: 200,
                  label: '${_commissionSliderValue.toStringAsFixed(1)}%',
                  onChanged: _onSliderChanged,
                ),
              ),
              const Text('100%', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),

          // Save button
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Сохранить ставку',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
