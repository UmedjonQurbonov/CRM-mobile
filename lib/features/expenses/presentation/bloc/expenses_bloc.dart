import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expenses_repository.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

/// BLoC managing operational business expenses, filtering, and mutations.
class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final ExpensesRepository expensesRepository;

  ExpensesBloc({required this.expensesRepository})
      : super(const ExpensesInitial()) {
    on<ExpensesFetchRequested>(_onFetchRequested);
    on<ExpenseCreateSubmitted>(_onCreateSubmitted);
    on<ExpenseDeleteSubmitted>(_onDeleteSubmitted);
    on<ExpenseCategoryFilterChanged>(_onCategoryFilterChanged);
    on<ExpenseDateRangeFilterChanged>(_onDateRangeFilterChanged);
  }

  Future<void> _onFetchRequested(
    ExpensesFetchRequested event,
    Emitter<ExpensesState> emit,
  ) async {
    final currentState = state;
    final isLoadMore = event.isLoadMore && currentState is ExpensesLoaded;

    String? category = event.category;
    DateTime? fromDate = event.fromDate;
    DateTime? toDate = event.toDate;

    if (currentState is ExpensesLoaded && !event.refresh && !isLoadMore) {
      category ??= currentState.selectedCategory;
      fromDate ??= currentState.fromDate;
      toDate ??= currentState.toDate;
    }

    final offset = isLoadMore ? currentState.expenses.length : 0;
    const limit = 20;

    if (!isLoadMore) {
      emit(ExpensesLoading(isFirstFetch: currentState is! ExpensesLoaded));
    }

    try {
      final response = await expensesRepository.getExpenses(
        category: category,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
      );

      final List<ExpenseEntity> updatedList;
      if (isLoadMore) {
        updatedList = List.from(currentState.expenses)..addAll(response.items);
      } else {
        updatedList = response.items;
      }

      emit(
        ExpensesLoaded(
          expenses: updatedList,
          total: response.total,
          offset: offset,
          hasMore: response.hasMore,
          selectedCategory: category,
          fromDate: fromDate,
          toDate: toDate,
        ),
      );
    } catch (e) {
      emit(ExpensesFailure(e.toString()));
    }
  }

  Future<void> _onCreateSubmitted(
    ExpenseCreateSubmitted event,
    Emitter<ExpensesState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExpensesLoaded) {
      emit(currentState.copyWith(clearFeedback: true));
    }

    try {
      await expensesRepository.createExpense(event.params);
      // Re-fetch to synchronize state with server
      add(
        ExpensesFetchRequested(
          category: currentState is ExpensesLoaded
              ? currentState.selectedCategory
              : null,
          fromDate:
              currentState is ExpensesLoaded ? currentState.fromDate : null,
          toDate: currentState is ExpensesLoaded ? currentState.toDate : null,
          refresh: true,
        ),
      );
    } catch (e) {
      emit(ExpensesFailure('Не удалось создать расход: $e'));
    }
  }

  Future<void> _onDeleteSubmitted(
    ExpenseDeleteSubmitted event,
    Emitter<ExpensesState> emit,
  ) async {
    final currentState = state;
    try {
      await expensesRepository.deleteExpense(event.id);

      if (currentState is ExpensesLoaded) {
        final updatedList =
            currentState.expenses.where((e) => e.id != event.id).toList();
        emit(
          currentState.copyWith(
            expenses: updatedList,
            total: (currentState.total - 1).clamp(0, double.infinity).toInt(),
            actionFeedback: 'Расход успешно удален',
          ),
        );
      } else {
        add(const ExpensesFetchRequested(refresh: true));
      }
    } catch (e) {
      emit(ExpensesFailure('Не удалось удалить расход: $e'));
    }
  }

  void _onCategoryFilterChanged(
    ExpenseCategoryFilterChanged event,
    Emitter<ExpensesState> emit,
  ) {
    final currentState = state;
    DateTime? fromDate;
    DateTime? toDate;
    if (currentState is ExpensesLoaded) {
      fromDate = currentState.fromDate;
      toDate = currentState.toDate;
    }

    add(
      ExpensesFetchRequested(
        category: event.category,
        fromDate: fromDate,
        toDate: toDate,
        refresh: true,
      ),
    );
  }

  void _onDateRangeFilterChanged(
    ExpenseDateRangeFilterChanged event,
    Emitter<ExpensesState> emit,
  ) {
    final currentState = state;
    String? category;
    if (currentState is ExpensesLoaded) {
      category = currentState.selectedCategory;
    }

    add(
      ExpensesFetchRequested(
        category: category,
        fromDate: event.fromDate,
        toDate: event.toDate,
        refresh: true,
      ),
    );
  }
}
