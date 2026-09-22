import 'package:dio/dio.dart';
import '../../../../core/errors/api_error.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/create_expense_params.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_remote_data_source.dart';
import '../models/create_expense_request_model.dart';

/// Concrete repository implementation for business operational expenses.
class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDataSource remoteDataSource;

  ExpensesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ExpenseListEntity> getExpenses({
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await remoteDataSource.getExpenses(
        category: category,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ExpenseEntity> createExpense(CreateExpenseParams params) async {
    try {
      final request = CreateExpenseRequestModel.fromEntity(params);
      return await remoteDataSource.createExpense(request);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await remoteDataSource.deleteExpense(id);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e).toFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
