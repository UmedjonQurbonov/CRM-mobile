import 'package:flutter/material.dart';

/// Screen for managing staff cashiers and commissions (Owner only).
class SellersScreen extends StatelessWidget {
  const SellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_rounded, size: 64, color: Color(0xFF3B82F6)),
            SizedBox(height: 16),
            Text(
              'Управление Продавцами',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Список сотрудников и настройка комиссии (Только Владелец)',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
