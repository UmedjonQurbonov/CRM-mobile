import 'package:flutter/material.dart';

/// Dashboard Overview screen for business owner.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_rounded, size: 64, color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text(
              'Панель Управления (Владелец)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Сводные показатели выручки, маржи и операционной деятельности',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
