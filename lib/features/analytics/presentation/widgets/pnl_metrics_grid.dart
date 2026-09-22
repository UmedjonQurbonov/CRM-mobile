import 'package:flutter/material.dart';
import '../../domain/entities/analytics_summary_entity.dart';

/// Grid displaying key P&L metrics with explicit mathematical formulas and indicators.
class PnlMetricsGrid extends StatelessWidget {
  final AnalyticsSummaryEntity summary;

  const PnlMetricsGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isProfitable = summary.isProfitable;
    final totalDeductions = summary.totalExpenses + summary.totalCommissions;

    return Column(
      children: [
        // Row 1: Revenue (R) & Gross Profit (GP)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Выручка (R)',
                subtitle: 'Себестоимость (C): ${summary.costOfGoodsSold.toStringAsFixed(2)} TJS',
                value: '${summary.revenue.toStringAsFixed(2)} TJS',
                caption: '${summary.totalOrders} чеков',
                accentColor: const Color(0xFF6366F1),
                icon: Icons.trending_up_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Валовая прибыль (GP)',
                subtitle: 'GP = R - C',
                value: '${summary.grossProfit.toStringAsFixed(2)} TJS',
                caption: 'Маржинальный доход',
                accentColor: const Color(0xFF3B82F6),
                icon: Icons.account_balance_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Expenses & Commissions (E + Comm) & Net Profit (NP)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Расходы и комиссии',
                subtitle: 'E: ${summary.totalExpenses.toStringAsFixed(2)} | Comm: ${summary.totalCommissions.toStringAsFixed(2)}',
                value: '${totalDeductions.toStringAsFixed(2)} TJS',
                caption: 'E + Comm',
                accentColor: const Color(0xFFF59E0B),
                icon: Icons.receipt_long_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isProfitable
                        ? [
                            const Color(0xFF064E3B),
                            const Color(0xFF1E293B),
                          ]
                        : [
                            const Color(0xFF7F1D1D),
                            const Color(0xFF1E293B),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isProfitable
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Чистая прибыль (NP)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isProfitable
                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                : const Color(0xFFEF4444).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isProfitable ? 'Прибыль' : 'Убыток',
                            style: TextStyle(
                              color: isProfitable
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFF87171),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${summary.netProfit.toStringAsFixed(2)} TJS',
                      style: TextStyle(
                        color: isProfitable
                            ? const Color(0xFF34D399)
                            : const Color(0xFFF87171),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'NP = GP - E - Comm',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String subtitle,
    required String value,
    required String caption,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: accentColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
