import 'package:decimal/decimal.dart';
import '../../domain/entities/seller_entity.dart';

/// DTO for parsing `http.UserDTO` representing a seller cashier.
class SellerModel extends SellerEntity {
  const SellerModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.role,
    required super.commissionRate,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    final rawRate = json['commission_rate'];
    final Decimal commissionRate = rawRate != null
        ? Decimal.parse(rawRate.toString())
        : Decimal.zero;

    return SellerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'seller',
      commissionRate: commissionRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'commission_rate': commissionRate.toStringAsFixed(2),
    };
  }
}
