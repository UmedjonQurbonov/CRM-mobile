import '../entities/create_expense_params.dart';
import '../entities/expense_entity.dart';

/// Contract for managing operational business expenses.
abstract interface class ExpensesRepository {
  /// Fetches a paginated list of expenses with optional category and date filters.
  Future<ExpenseListEntity> getExpenses({
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  });

  /// Records a new operational expense.
  Future<ExpenseEntity> createExpense(CreateExpenseParams params);

  /// Deletes an expense by its unique identifier.
  Future<void> deleteExpense(String id);
}
