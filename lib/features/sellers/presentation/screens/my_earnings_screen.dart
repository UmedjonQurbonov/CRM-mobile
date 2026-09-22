import 'package:flutter/material.dart';

/// Screen displaying calling seller's earnings, commission, and order counts.
class MyEarningsScreen extends StatelessWidget {
  const MyEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monetization_on_rounded, size: 64, color: Color(0xFF10B981)),
            SizedBox(height: 16),
            Text(
              'Мой Заработок',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Статистика продаж и начисленная комиссия продавца',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
