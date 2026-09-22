import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Base event for POS Cart state management.
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Adds a product to cart or increments its quantity.
class CartItemAdded extends CartEvent {
  final ProductEntity product;
  final int quantity;

  const CartItemAdded(this.product, [this.quantity = 1]);

  @override
  List<Object?> get props => [product, quantity];
}

/// Removes a product entirely from the cart by its product ID.
class CartItemRemoved extends CartEvent {
  final String productId;

  const CartItemRemoved(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Modifies quantity of a product in the cart.
class CartQuantityChanged extends CartEvent {
  final String productId;
  final int newQuantity;

  const CartQuantityChanged(this.productId, this.newQuantity);

  @override
  List<Object?> get props => [productId, newQuantity];
}

/// Updates selected payment method (cash, card, transfer).
class CartPaymentMethodSelected extends CartEvent {
  final String paymentMethod;

  const CartPaymentMethodSelected(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

/// Clears all items in the cart and resets payment method.
class CartCleared extends CartEvent {
  const CartCleared();
}
