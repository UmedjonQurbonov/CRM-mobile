import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Parameters for registering a new cashier seller.
class CreateSellerParams extends Equatable {
  final String name;
  final String phone;
  final String password;
  final Decimal commissionRate;

  const CreateSellerParams({
    required this.name,
    required this.phone,
    required this.password,
    required this.commissionRate,
  });

  @override
  List<Object?> get props => [name, phone, password, commissionRate];
}
