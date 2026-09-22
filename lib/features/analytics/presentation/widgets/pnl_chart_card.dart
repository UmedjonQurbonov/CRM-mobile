import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/analytics_summary_entity.dart';

/// Interactive chart visualizing P&L financial structure and margin ratios.
class PnlChartCard extends StatefulWidget {
  final AnalyticsSummaryEntity summary;

  const PnlChartCard({super.key, required this.summary});

  @override
  State<PnlChartCard> createState() => _PnlChartCardState();
}

class _PnlChartCardState extends State<PnlChartCard> {
  int _selectedChartIndex = 0; // 0: Structure (Pie), 1: P&L Comparison (Bar)

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Row(
                children: [
                  Icon(Icons.pie_chart_rounded, color: Color(0xFF6366F1), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Финансовая структура',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildChartToggleButton('Круговая', 0),
                    _buildChartToggleButton('Столбцы', 1),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _selectedChartIndex == 0
                ? _buildPieChart(widget.summary)
                : _buildBarChart(widget.summary),
          ),
          const SizedBox(height: 16),
          _buildLegend(widget.summary),
        ],
      ),
    );
  }

  Widget _buildChartToggleButton(String label, int index) {
    final isSelected = _selectedChartIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(AnalyticsSummaryEntity s) {
    final cogs = double.tryParse(s.costOfGoodsSold.toString()) ?? 0.0;
    final expenses = double.tryParse(s.totalExpenses.toString()) ?? 0.0;
    final commissions = double.tryParse(s.totalCommissions.toString()) ?? 0.0;
    final netProfit = double.tryParse(s.netProfit.toString()) ?? 0.0;

    final totalValue = cogs + expenses + commissions + (netProfit > 0 ? netProfit : 0.0);

    if (totalValue <= 0) {
      return const Center(
        child: Text(
          'Нет данных за выбранный период',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    final sections = <PieChartSectionData>[];

    if (cogs > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF64748B),
          value: cogs,
          title: '${((cogs / totalValue) * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (expenses > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFEF4444),
          value: expenses,
          title: '${((expenses / totalValue) * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (commissions > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFF59E0B),
          value: commissions,
          title: '${((commissions / totalValue) * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (netProfit > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF10B981),
          value: netProfit,
          title: '${((netProfit / totalValue) * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 36,
        sectionsSpace: 3,
      ),
    );
  }

  Widget _buildBarChart(AnalyticsSummaryEntity s) {
    final revenue = double.tryParse(s.revenue.toString()) ?? 0.0;
    final totalCosts = (double.tryParse(s.costOfGoodsSold.toString()) ?? 0.0) +
        (double.tryParse(s.totalExpenses.toString()) ?? 0.0) +
        (double.tryParse(s.totalCommissions.toString()) ?? 0.0);
    final netProfit = double.tryParse(s.netProfit.toString()) ?? 0.0;

    final maxY = [revenue, totalCosts, netProfit.abs()].reduce((a, b) => a > b ? a : b);
    final effectiveMaxY = maxY > 0 ? maxY * 1.2 : 100.0;

    return BarChart(
      BarChartData(
        maxY: effectiveMaxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Выручка', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    );
                  case 1:
                    return const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Затраты', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    );
                  case 2:
                    return const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Прибыль', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    );
                  default:
                    return const SizedBox();
                }
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: revenue,
                color: const Color(0xFF6366F1),
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: totalCosts,
                color: const Color(0xFFF59E0B),
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: netProfit >= 0 ? netProfit : 0,
                color: netProfit >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(AnalyticsSummaryEntity s) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Себестоимость', const Color(0xFF64748B), s.costOfGoodsSold),
        _buildLegendItem('Расходы', const Color(0xFFEF4444), s.totalExpenses),
        _buildLegendItem('Комиссии', const Color(0xFFF59E0B), s.totalCommissions),
        _buildLegendItem(
          'Чистая прибыль',
          s.isProfitable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          s.netProfit,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, Decimal amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ${amount.toStringAsFixed(2)} TJS',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
        ),
      ],
    );
  }
}
