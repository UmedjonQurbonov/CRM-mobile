import 'package:flutter/material.dart';

/// Placeholder screen for Products Catalog (Phase 2).
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_rounded, size: 64, color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text(
              'Каталог Товаров и Склад',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Каталог, остатки и QR-сканер (Фаза 2)',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
