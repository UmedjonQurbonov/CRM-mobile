import 'package:equatable/equatable.dart';
import '../../../orders/domain/entities/order_entity.dart';

/// Base state for checkout processing.
abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

/// Ready for checkout submission.
class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

/// Sending checkout payload to backend.
class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

/// Order successfully created and registered.
class CheckoutSuccess extends CheckoutState {
  final OrderEntity order;

  const CheckoutSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

/// Checkout failed (e.g. INSUFFICIENT_STOCK or network error).
class CheckoutFailure extends CheckoutState {
  final String message;
  final String? code;

  const CheckoutFailure(this.message, {this.code});

  bool get isInsufficientStock =>
      code == 'INSUFFICIENT_STOCK' ||
      message.toLowerCase().contains('stock') ||
      code == 'HTTP_409';

  @override
  List<Object?> get props => [message, code];
}
