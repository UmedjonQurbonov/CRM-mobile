import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Domain representation of an authenticated user.
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String role;
  final Decimal commissionRate;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.commissionRate,
  });

  /// Role check: returns true if the user is a business owner.
  bool get isOwner => role == 'owner';

  /// Role check: returns true if the user is a cashier/seller.
  bool get isSeller => role == 'seller';

  @override
  List<Object?> get props => [id, name, phone, role, commissionRate];

  @override
  String toString() =>
      'UserEntity(id: $id, name: $name, phone: $phone, role: $role, commissionRate: $commissionRate)';
}
