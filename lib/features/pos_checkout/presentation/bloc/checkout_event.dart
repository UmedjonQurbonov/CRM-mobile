import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

/// Base event for checkout execution.
abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

/// Submits active cart items for payment processing and receipt generation.
class CheckoutSubmitted extends CheckoutEvent {
  final List<CartItemEntity> items;
  final String paymentMethod;

  const CheckoutSubmitted({
    required this.items,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [items, paymentMethod];
}

/// Resets checkout status back to initial.
class CheckoutReset extends CheckoutEvent {
  const CheckoutReset();
}
