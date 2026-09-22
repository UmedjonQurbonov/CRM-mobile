import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/create_seller_params.dart';

abstract class SellersEvent extends Equatable {
  const SellersEvent();

  @override
  List<Object?> get props => [];
}

/// Request to fetch or refresh sellers list.
class SellersFetchRequested extends SellersEvent {
  final bool refresh;

  const SellersFetchRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

/// Dispatched when the owner submits a new seller registration form.
class SellerCreateSubmitted extends SellersEvent {
  final CreateSellerParams params;

  const SellerCreateSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}

/// Dispatched when the owner updates a seller's sales commission rate.
class SellerCommissionUpdateSubmitted extends SellersEvent {
  final String sellerId;
  final Decimal newCommissionRate;

  const SellerCommissionUpdateSubmitted({
    required this.sellerId,
    required this.newCommissionRate,
  });

  @override
  List<Object?> get props => [sellerId, newCommissionRate];
}
