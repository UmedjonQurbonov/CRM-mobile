import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Domain entity representing a staff cashier/seller.
class SellerEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String role;
  final Decimal commissionRate;

  const SellerEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.commissionRate,
  });

  /// Formatted commission rate percentage string (e.g. "5.00%").
  String get commissionFormatted => '${commissionRate.toStringAsFixed(2)}%';

  SellerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    Decimal? commissionRate,
  }) {
    return SellerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      commissionRate: commissionRate ?? this.commissionRate,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, role, commissionRate];
}
