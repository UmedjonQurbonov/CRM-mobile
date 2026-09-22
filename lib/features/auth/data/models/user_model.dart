import 'package:decimal/decimal.dart';
import '../../domain/entities/user_entity.dart';

/// Data model representing http.UserDTO from backend OpenAPI contract.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.role,
    required super.commissionRate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'seller',
      commissionRate: _parseDecimal(json['commission_rate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role,
        'commission_rate': commissionRate.toString(),
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        phone: phone,
        role: role,
        commissionRate: commissionRate,
      );

  static Decimal _parseDecimal(dynamic value) {
    if (value == null) return Decimal.zero;
    if (value is num) return Decimal.parse(value.toString());
    if (value is String) {
      final cleaned = value.replaceAll('%', '').trim();
      return Decimal.tryParse(cleaned) ?? Decimal.zero;
    }
    return Decimal.zero;
  }
}
