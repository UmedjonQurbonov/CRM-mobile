import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Represents a product item with selected quantity in the POS cart.
class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({
    required this.product,
    required this.quantity,
  });

  /// Subtotal calculated as unit selling price multiplied by quantity.
  Decimal get subtotal => product.sellingPrice * Decimal.fromInt(quantity);

  /// Returns whether adding [additional] quantity exceeds available warehouse stock.
  bool canAdd(int additional) => (quantity + additional) <= product.stockQuantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}
