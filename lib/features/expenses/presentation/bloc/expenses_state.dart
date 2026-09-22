import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class ExpensesInitial extends ExpensesState {
  const ExpensesInitial();
}

/// Loading state for initial fetch, pagination, or submission.
class ExpensesLoading extends ExpensesState {
  final bool isFirstFetch;
  final bool isSubmitting;

  const ExpensesLoading({
    this.isFirstFetch = false,
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [isFirstFetch, isSubmitting];
}

/// Successfully loaded expenses with computed total sum in Decimal.
class ExpensesLoaded extends ExpensesState {
  final List<ExpenseEntity> expenses;
  final int total;
  final int offset;
  final bool hasMore;
  final String? selectedCategory;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? actionFeedback;

  const ExpensesLoaded({
    required this.expenses,
    required this.total,
    required this.offset,
    required this.hasMore,
    this.selectedCategory,
    this.fromDate,
    this.toDate,
    this.actionFeedback,
  });

  /// Total sum computed using exact Decimal arithmetic.
  Decimal get totalAmountForPeriod =>
      expenses.fold(Decimal.zero, (sum, item) => sum + item.amount);

  ExpensesLoaded copyWith({
    List<ExpenseEntity>? expenses,
    int? total,
    int? offset,
    bool? hasMore,
    String? selectedCategory,
    bool clearCategory = false,
    DateTime? fromDate,
    bool clearFromDate = false,
    DateTime? toDate,
    bool clearToDate = false,
    String? actionFeedback,
    bool clearFeedback = false,
  }) {
    return ExpensesLoaded(
      expenses: expenses ?? this.expenses,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      actionFeedback:
          clearFeedback ? null : (actionFeedback ?? this.actionFeedback),
    );
  }

  @override
  List<Object?> get props => [
        expenses,
        total,
        offset,
        hasMore,
        selectedCategory,
        fromDate,
        toDate,
        actionFeedback,
      ];
}

/// Failure state when an operation fails.
class ExpensesFailure extends ExpensesState {
  final String message;

  const ExpensesFailure(this.message);

  @override
  List<Object?> get props => [message];
}
