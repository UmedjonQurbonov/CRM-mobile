import 'package:intl/intl.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/create_expense_request_model.dart';
import '../models/expense_list_response_model.dart';
import '../models/expense_response_model.dart';

/// Interface for operational expenses remote data source.
abstract interface class ExpensesRemoteDataSource {
  Future<ExpenseListResponseModel> getExpenses({
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  });

  Future<ExpenseResponseModel> createExpense(CreateExpenseRequestModel request);

  Future<void> deleteExpense(String id);
}

/// Implementation using configured DioClient with automatic auth tokens.
class ExpensesRemoteDataSourceImpl implements ExpensesRemoteDataSource {
  final DioClient client;

  ExpensesRemoteDataSourceImpl({required this.client});

  @override
  Future<ExpenseListResponseModel> getExpenses({
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (fromDate != null) {
      queryParams['from_date'] = DateFormat('yyyy-MM-dd').format(fromDate);
    }
    if (toDate != null) {
      queryParams['to_date'] = DateFormat('yyyy-MM-dd').format(toDate);
    }

    final response = await client.get(
      ApiEndpoints.expenses,
      queryParameters: queryParams,
    );

    return ExpenseListResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ExpenseResponseModel> createExpense(
    CreateExpenseRequestModel request,
  ) async {
    final response = await client.post(
      ApiEndpoints.expenses,
      data: request.toJson(),
    );

    return ExpenseResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    await client.delete(ApiEndpoints.expenseById(id));
  }
}
