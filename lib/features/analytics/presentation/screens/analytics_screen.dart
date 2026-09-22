import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

/// Screen for financial analytics, top products and seller rankings (Owner only).
/// Delegates to [DashboardScreen] to provide unified, reactive P&L reporting.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
