import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

/// State representing items and totals in POS cashier cart.
class CartState extends Equatable {
  final List<CartItemEntity> items;
  final String paymentMethod;
  final String? warningMessage;

  const CartState({
    this.items = const [],
    this.paymentMethod = 'cash',
    this.warningMessage,
  });

  /// Total count of individual units in cart.
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  /// Total sum computed with exact Decimal arithmetic.
  Decimal get totalAmount =>
      items.fold(Decimal.zero, (sum, i) => sum + i.subtotal);

  Decimal get subtotal => totalAmount;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartState copyWith({
    List<CartItemEntity>? items,
    String? paymentMethod,
    String? warningMessage,
    bool clearWarning = false,
  }) {
    return CartState(
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      warningMessage:
          clearWarning ? null : (warningMessage ?? this.warningMessage),
    );
  }

  @override
  List<Object?> get props => [items, paymentMethod, warningMessage];
}
