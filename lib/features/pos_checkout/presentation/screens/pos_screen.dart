import 'package:flutter/material.dart';

/// Placeholder screen for POS Checkout (Phase 3).
class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.point_of_sale_rounded, size: 64, color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text(
              'POS Терминал Кассы',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Модуль быстрых продаж и сканирования товаров (Фаза 3)',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
