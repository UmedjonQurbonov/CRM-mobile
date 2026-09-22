import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// BLoC managing POS shopping cart, quantity updates, stock limits, and payment methods.
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartQuantityChanged>(_onQuantityChanged);
    on<CartPaymentMethodSelected>(_onPaymentMethodSelected);
    on<CartCleared>(_onCleared);
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final product = event.product;
    final maxStock = product.stockQuantity;

    if (maxStock <= 0) {
      emit(
        state.copyWith(
          warningMessage: 'Товар "${product.name}" закончился на складе.',
        ),
      );
      return;
    }

    final existingIndex =
        state.items.indexWhere((i) => i.product.id == product.id);

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final requestedQty = existing.quantity + event.quantity;

      if (requestedQty > maxStock) {
        final updatedList = List<CartItemEntity>.from(state.items);
        updatedList[existingIndex] = existing.copyWith(quantity: maxStock);
        emit(
          state.copyWith(
            items: updatedList,
            warningMessage:
                'Достигнут лимит склада для "${product.name}": $maxStock шт.',
          ),
        );
      } else {
        final updatedList = List<CartItemEntity>.from(state.items);
        updatedList[existingIndex] =
            existing.copyWith(quantity: requestedQty);
        emit(
          state.copyWith(
            items: updatedList,
            clearWarning: true,
          ),
        );
      }
    } else {
      final initialQty = event.quantity.clamp(1, maxStock);
      final newItem = CartItemEntity(product: product, quantity: initialQty);
      final updatedList = List<CartItemEntity>.from(state.items)..add(newItem);

      String? warning;
      if (event.quantity > maxStock) {
        warning =
            'Достигнут лимит склада для "${product.name}": $maxStock шт.';
      }

      emit(
        state.copyWith(
          items: updatedList,
          warningMessage: warning,
          clearWarning: warning == null,
        ),
      );
    }
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final updatedList =
        state.items.where((i) => i.product.id != event.productId).toList();
    emit(state.copyWith(items: updatedList, clearWarning: true));
  }

  void _onQuantityChanged(
      CartQuantityChanged event, Emitter<CartState> emit) {
    final index = state.items.indexWhere((i) => i.product.id == event.productId);
    if (index < 0) return;

    final existing = state.items[index];

    if (event.newQuantity <= 0) {
      final updatedList = List<CartItemEntity>.from(state.items)..removeAt(index);
      emit(state.copyWith(items: updatedList, clearWarning: true));
      return;
    }

    final maxStock = existing.product.stockQuantity;
    if (event.newQuantity > maxStock) {
      final updatedList = List<CartItemEntity>.from(state.items);
      updatedList[index] = existing.copyWith(quantity: maxStock);
      emit(
        state.copyWith(
          items: updatedList,
          warningMessage:
              'Достигнут лимит склада для "${existing.product.name}": $maxStock шт.',
        ),
      );
    } else {
      final updatedList = List<CartItemEntity>.from(state.items);
      updatedList[index] = existing.copyWith(quantity: event.newQuantity);
      emit(state.copyWith(items: updatedList, clearWarning: true));
    }
  }

  void _onPaymentMethodSelected(
      CartPaymentMethodSelected event, Emitter<CartState> emit) {
    emit(state.copyWith(paymentMethod: event.paymentMethod, clearWarning: true));
  }

  void _onCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
