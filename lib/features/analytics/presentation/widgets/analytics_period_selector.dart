import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../bloc/analytics_event.dart';

/// Period selector component with predefined ranges (Today, Month) and custom DateRangePicker.
class AnalyticsPeriodSelector extends StatelessWidget {
  final AnalyticsPeriodType selectedPeriod;
  final DateTime? from;
  final DateTime? to;
  final void Function(AnalyticsPeriodType type, DateTime? customFrom, DateTime? customTo) onPeriodSelected;

  const AnalyticsPeriodSelector({
    super.key,
    required this.selectedPeriod,
    this.from,
    this.to,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            context,
            label: 'Сегодня',
            period: AnalyticsPeriodType.today,
            isSelected: selectedPeriod == AnalyticsPeriodType.today,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Текущий месяц',
            period: AnalyticsPeriodType.thisMonth,
            isSelected: selectedPeriod == AnalyticsPeriodType.thisMonth,
          ),
          const SizedBox(width: 8),
          _buildCustomChip(context),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required AnalyticsPeriodType period,
    required bool isSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onPeriodSelected(period, null, null);
        }
      },
      selectedColor: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildCustomChip(BuildContext context) {
    final isCustom = selectedPeriod == AnalyticsPeriodType.custom;
    final dateFormat = DateFormat('dd.MM.yyyy');
    String label = 'Выбрать даты';
    if (isCustom && from != null && to != null) {
      label = '${dateFormat.format(from!)} - ${dateFormat.format(to!)}';
    }

    return ActionChip(
      avatar: Icon(
        Icons.calendar_month_rounded,
        size: 16,
        color: isCustom ? Colors.white : const Color(0xFF94A3B8),
      ),
      label: Text(label),
      backgroundColor: isCustom ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: isCustom ? Colors.white : const Color(0xFF94A3B8),
        fontWeight: isCustom ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isCustom ? const Color(0xFF818CF8) : const Color(0xFF334155),
        ),
      ),
      onPressed: () async {
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: now.add(const Duration(days: 365)),
          initialDateRange: from != null && to != null
              ? DateTimeRange(start: from!, end: to!)
              : DateTimeRange(
                  start: DateTime(now.year, now.month, 1),
                  end: now,
                ),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF6366F1),
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E293B),
                  onSurface: Colors.white,
                ),
                dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E293B)),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          onPeriodSelected(AnalyticsPeriodType.custom, picked.start, picked.end);
        }
      },
    );
  }
}
