import '../../domain/entities/create_seller_params.dart';

/// Request body mapping to `http.CreateSellerRequest`.
class CreateSellerRequestModel {
  final String name;
  final String phone;
  final String password;
  final double commissionRate;

  const CreateSellerRequestModel({
    required this.name,
    required this.phone,
    required this.password,
    required this.commissionRate,
  });

  factory CreateSellerRequestModel.fromEntity(CreateSellerParams params) {
    return CreateSellerRequestModel(
      name: params.name,
      phone: params.phone,
      password: params.password,
      commissionRate: params.commissionRate.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
      'commission_rate': commissionRate,
    };
  }
}
