import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/create_seller_request_model.dart';
import '../models/seller_model.dart';
import '../models/update_commission_request_model.dart';

/// Interface for sellers remote data source.
abstract interface class SellersRemoteDataSource {
  Future<List<SellerModel>> getSellers();

  Future<SellerModel> createSeller(CreateSellerRequestModel request);

  Future<void> updateCommission(
    String sellerId,
    UpdateCommissionRequestModel request,
  );
}

/// Concrete implementation utilizing DioClient.
class SellersRemoteDataSourceImpl implements SellersRemoteDataSource {
  final DioClient client;

  SellersRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SellerModel>> getSellers() async {
    final response = await client.get(ApiEndpoints.sellers);
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => SellerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SellerModel> createSeller(CreateSellerRequestModel request) async {
    final response = await client.post(
      ApiEndpoints.sellers,
      data: request.toJson(),
    );
    return SellerModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> updateCommission(
    String sellerId,
    UpdateCommissionRequestModel request,
  ) async {
    await client.patch(
      ApiEndpoints.sellerCommission(sellerId),
      data: request.toJson(),
    );
  }
}
