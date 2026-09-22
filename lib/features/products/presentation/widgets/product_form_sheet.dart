import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_params.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';

/// Modal bottom sheet form for Owner to create or edit product details.
class ProductFormSheet extends StatefulWidget {
  final ProductEntity? initialProduct;
  final String? initialQrCode;

  const ProductFormSheet({
    super.key,
    this.initialProduct,
    this.initialQrCode,
  });

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _qrCodeController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;

  bool get _isEditing => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _qrCodeController =
        TextEditingController(text: p?.qrCode ?? widget.initialQrCode ?? '');
    _sellingPriceController =
        TextEditingController(text: p?.sellingPrice.toString() ?? '');
    _costPriceController =
        TextEditingController(text: p?.costPrice.toString() ?? '');
    _stockController =
        TextEditingController(text: p != null ? p.stockQuantity.toString() : '10');
    _minStockController =
        TextEditingController(text: p != null ? p.minStockAlert.toString() : '5');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _qrCodeController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final sku = _skuController.text.trim();
      final qrCode = _qrCodeController.text.trim();
      final sellingPrice =
          Decimal.tryParse(_sellingPriceController.text.trim()) ?? Decimal.zero;
      final costPrice =
          Decimal.tryParse(_costPriceController.text.trim()) ?? Decimal.zero;
      final stockQuantity = int.tryParse(_stockController.text.trim()) ?? 0;
      final minStockAlert = int.tryParse(_minStockController.text.trim()) ?? 5;

      if (_isEditing) {
        context.read<ProductsBloc>().add(
              ProductUpdateSubmitted(
                id: widget.initialProduct!.id,
                params: UpdateProductParams(
                  name: name,
                  sku: sku,
                  qrCode: qrCode,
                  costPrice: costPrice,
                  sellingPrice: sellingPrice,
                  stockQuantity: stockQuantity,
                  minStockAlert: minStockAlert,
                ),
              ),
            );
      } else {
        context.read<ProductsBloc>().add(
              ProductCreateSubmitted(
                CreateProductParams(
                  name: name,
                  sku: sku,
                  qrCode: qrCode,
                  costPrice: costPrice,
                  sellingPrice: sellingPrice,
                  stockQuantity: stockQuantity,
                  minStockAlert: minStockAlert,
                ),
              ),
            );
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Редактировать товар' : 'Новый товар',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField('Название товара', _nameController, 'например: iPhone 15 Pro'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField('Артикул (SKU)', _skuController, 'IPHONE-15-BLK'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Штрихкод / QR', _qrCodeController, 'QR-15-001'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'Цена продажи',
                      _sellingPriceController,
                      '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      'Себестоимость',
                      _costPriceController,
                      '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      'Остаток на складе',
                      _stockController,
                      '50',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      'Порог алертов',
                      _minStockController,
                      '5',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Сохранить изменения' : 'Создать товар',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFCBD5E1),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Обязательное поле';
            }
            return null;
          },
        ),
      ],
    );
  }
}
