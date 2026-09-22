import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

/// Single item in checkout payload matching usecase.CartItemDTO.
class CartItemRequestModel extends Equatable {
  final String productId;
  final int quantity;

  const CartItemRequestModel({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };

  @override
  List<Object?> get props => [productId, quantity];
}

/// Payload sent to POST /api/v1/orders matching usecase.CheckoutRequestDTO.
class CheckoutRequestModel extends Equatable {
  final List<CartItemRequestModel> items;
  final String paymentMethod;

  const CheckoutRequestModel({
    required this.items,
    required this.paymentMethod,
  });

  factory CheckoutRequestModel.fromEntities({
    required List<CartItemEntity> items,
    required String paymentMethod,
  }) {
    return CheckoutRequestModel(
      items: items
          .map((item) => CartItemRequestModel(
                productId: item.product.id,
                quantity: item.quantity,
              ))
          .toList(),
      paymentMethod: paymentMethod,
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        'payment_method': paymentMethod,
      };

  @override
  List<Object?> get props => [items, paymentMethod];
}
