import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/expense_entity.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';
import '../bloc/expenses_state.dart';
import '../widgets/expense_form_sheet.dart';

/// Screen for recording and reviewing business operational expenses (Owner only).
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<ExpensesBloc>();
      return const _ExpensesView();
    } catch (_) {
      return BlocProvider(
        create: (_) => sl<ExpensesBloc>()..add(const ExpensesFetchRequested()),
        child: const _ExpensesView(),
      );
    }
  }
}

class _ExpensesView extends StatefulWidget {
  const _ExpensesView();

  @override
  State<_ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<_ExpensesView> {
  static const List<Map<String, String?>> _categories = [
    {'key': null, 'label': 'Все категории'},
    {'key': 'utilities', 'label': 'Коммуналка'},
    {'key': 'rent', 'label': 'Аренда'},
    {'key': 'salary', 'label': 'Зарплата'},
    {'key': 'logistics', 'label': 'Логистика'},
    {'key': 'marketing', 'label': 'Реклама'},
    {'key': 'supplies', 'label': 'Расходники'},
    {'key': 'other', 'label': 'Прочее'},
  ];

  Future<void> _pickDateRange(BuildContext context, ExpensesLoaded state) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: state.fromDate != null && state.toDate != null
          ? DateTimeRange(start: state.fromDate!, end: state.toDate!)
          : DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: now,
            ),
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null && context.mounted) {
      context.read<ExpensesBloc>().add(
            ExpenseDateRangeFilterChanged(
              fromDate: picked.start,
              toDate: picked.end,
            ),
          );
    }
  }

  void _confirmDelete(BuildContext context, ExpenseEntity expense) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Удалить расход?'),
        content: Text(
          'Вы действительно хотите удалить расход на сумму ${expense.amount.toStringAsFixed(2)} TJS (${expense.categoryLocalized})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<ExpensesBloc>().add(ExpenseDeleteSubmitted(expense.id));
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Операционные расходы',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ExpenseFormSheet.show(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новый расход'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ExpensesBloc, ExpensesState>(
        listener: (context, state) {
          if (state is ExpensesLoaded && state.actionFeedback != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionFeedback!),
                backgroundColor: Colors.green[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ExpensesFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpensesLoading && state.isFirstFetch) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpensesFailure && state is! ExpensesLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 54, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ExpensesBloc>().add(
                          const ExpensesFetchRequested(refresh: true),
                        ),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final loadedState = state is ExpensesLoaded ? state : null;
          final expenses = loadedState?.expenses ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExpensesBloc>().add(
                    const ExpensesFetchRequested(refresh: true),
                  );
            },
            child: CustomScrollView(
              slivers: [
                // Filter bar & Summary Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Summary Banner
                        _buildSummaryBanner(context, loadedState),
                        const SizedBox(height: 16),

                        // Date filter bar
                        _buildDateFilterRow(context, loadedState),
                        const SizedBox(height: 12),

                        // Category Chips Filter
                        _buildCategoryFilterRow(context, loadedState),
                      ],
                    ),
                  ),
                ),

                // Expenses List
                if (expenses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.withAlpha(120),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Расходы за выбранный период не найдены',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    sliver: SliverList.separated(
                      itemCount: expenses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return _buildExpenseCard(context, expense);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryBanner(BuildContext context, ExpensesLoaded? state) {
    final totalAmount = state?.totalAmountForPeriod ?? 0;
    final count = state?.total ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEF4444).withAlpha(220),
            const Color(0xFFDC2626),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Суммарные расходы',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count записей',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${totalAmount.toString()} TJS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterRow(BuildContext context, ExpensesLoaded? state) {
    final from = state?.fromDate;
    final to = state?.toDate;

    final dateLabel = from != null && to != null
        ? '${DateFormat('dd.MM').format(from)} - ${DateFormat('dd.MM.yyyy').format(to)}'
        : 'За всё время';

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: state != null ? () => _pickDateRange(context, state) : null,
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: Text(dateLabel),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (from != null || to != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            tooltip: 'Сбросить даты',
            onPressed: () {
              context.read<ExpensesBloc>().add(
                    const ExpenseDateRangeFilterChanged(
                      fromDate: null,
                      toDate: null,
                    ),
                  );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryFilterRow(BuildContext context, ExpensesLoaded? state) {
    final selectedCategory = state?.selectedCategory;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((c) {
          final isSelected = selectedCategory == c['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(c['label']!),
              selected: isSelected,
              onSelected: (_) {
                context.read<ExpensesBloc>().add(
                      ExpenseCategoryFilterChanged(c['key']),
                    );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, ExpenseEntity expense) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withAlpha(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(expense.categoryIcon, color: Colors.red[600], size: 24),
            ),
            const SizedBox(width: 14),

            // Category & Comment & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.categoryLocalized,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (expense.comment.isNotEmpty) ...[
                    Text(
                      expense.comment,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    DateFormat('dd.MM.yyyy').format(expense.expenseDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Amount & Delete Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${expense.amount.toStringAsFixed(2)} TJS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red[500],
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _confirmDelete(context, expense),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
