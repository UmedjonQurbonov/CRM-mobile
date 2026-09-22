import 'package:equatable/equatable.dart';
import '../../domain/entities/create_expense_params.dart';

abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches paginated expenses with optional date range and category filters.
class ExpensesFetchRequested extends ExpensesEvent {
  final String? category;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool refresh;
  final bool isLoadMore;

  const ExpensesFetchRequested({
    this.category,
    this.fromDate,
    this.toDate,
    this.refresh = false,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [category, fromDate, toDate, refresh, isLoadMore];
}

/// Dispatched when the user submits the new expense modal form.
class ExpenseCreateSubmitted extends ExpensesEvent {
  final CreateExpenseParams params;

  const ExpenseCreateSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}

/// Dispatched when an owner requests deletion of an expense entry.
class ExpenseDeleteSubmitted extends ExpensesEvent {
  final String id;

  const ExpenseDeleteSubmitted(this.id);

  @override
  List<Object?> get props => [id];
}

/// Filter by specific category.
class ExpenseCategoryFilterChanged extends ExpensesEvent {
  final String? category;

  const ExpenseCategoryFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

/// Filter by date range.
class ExpenseDateRangeFilterChanged extends ExpensesEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  const ExpenseDateRangeFilterChanged({this.fromDate, this.toDate});

  @override
  List<Object?> get props => [fromDate, toDate];
}
