import 'package:flutter/material.dart';

/// Screen for financial analytics, top products and seller rankings (Owner only).
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_rounded, size: 64, color: Color(0xFFF59E0B)),
            SizedBox(height: 16),
            Text(
              'Финансовая Аналитика',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Графики P&L, выручка и рейтинги (Только Владелец)',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
