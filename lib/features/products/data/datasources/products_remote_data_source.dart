import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_list_response_model.dart';
import '../models/product_model.dart';
import '../models/product_request_models.dart';

/// Remote data source interface for product inventory and QR operations.
abstract class ProductsRemoteDataSource {
  Future<ProductListResponseModel> getProducts({
    String? search,
    bool? lowStock,
    int limit = 20,
    int offset = 0,
  });

  Future<ProductModel> getProductByQr(String qrCode);

  Future<ProductModel> createProduct(CreateProductRequestModel request);

  Future<ProductModel> updateProduct(
    String id,
    UpdateProductRequestModel request,
  );
}

/// Implementation using configured [DioClient].
class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final DioClient client;

  ProductsRemoteDataSourceImpl({required this.client});

  @override
  Future<ProductListResponseModel> getProducts({
    String? search,
    bool? lowStock,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (lowStock != null) {
      queryParams['low_stock'] = lowStock;
    }

    final response = await client.get<Map<String, dynamic>>(
      ApiEndpoints.products,
      queryParameters: queryParams,
    );

    return ProductListResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<ProductModel> getProductByQr(String qrCode) async {
    final response = await client.get<Map<String, dynamic>>(
      ApiEndpoints.productByQr(qrCode),
    );

    return ProductModel.fromJson(response.data ?? {});
  }

  @override
  Future<ProductModel> createProduct(CreateProductRequestModel request) async {
    final response = await client.post<Map<String, dynamic>>(
      ApiEndpoints.products,
      data: request.toJson(),
    );

    return ProductModel.fromJson(response.data ?? {});
  }

  @override
  Future<ProductModel> updateProduct(
    String id,
    UpdateProductRequestModel request,
  ) async {
    final response = await client.put<Map<String, dynamic>>(
      ApiEndpoints.productById(id),
      data: request.toJson(),
    );

    return ProductModel.fromJson(response.data ?? {});
  }
}
