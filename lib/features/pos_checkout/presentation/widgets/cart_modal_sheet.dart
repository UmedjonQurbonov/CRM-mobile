import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import 'order_success_dialog.dart';

/// Modal bottom sheet displaying current cart items, payment selector, and checkout trigger.
class CartModalSheet extends StatelessWidget {
  const CartModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CartModalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          final order = state.order;
          // 1. Clear cart
          context.read<CartBloc>().add(const CartCleared());
          // 2. Reset checkout state
          context.read<CheckoutBloc>().add(const CheckoutReset());
          // 3. Close sheet
          Navigator.of(context).pop();
          // 4. Show success receipt
          OrderSuccessDialog.show(context, order);
        } else if (state is CheckoutFailure) {
          if (state.isInsufficientStock) {
            _showInsufficientStockDialog(context, state.message);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_cart_rounded, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Корзина (${cartState.totalItems})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (cartState.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          context.read<CartBloc>().add(const CartCleared());
                        },
                        icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                        label: const Text('Очистить'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[600],
                        ),
                      ),
                  ],
                ),

                // Stock limit warning banner
                if (cartState.warningMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withAlpha(80),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.deepOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cartState.warningMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Cart items list
                if (cartState.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.remove_shopping_cart_outlined,
                            size: 48,
                            color: Colors.grey.withAlpha(120),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Корзина пуста',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Добавьте товары из каталога или со сканера',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cartState.items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = cartState.items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              // Name & unit price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.product.sellingPrice.toStringAsFixed(2)} TJS / шт.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withAlpha(140),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity steppers
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme
                                      .surfaceContainerHighest
                                      .withAlpha(100),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        context.read<CartBloc>().add(
                                              CartQuantityChanged(
                                                item.product.id,
                                                item.quantity - 1,
                                              ),
                                            );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        context.read<CartBloc>().add(
                                              CartQuantityChanged(
                                                item.product.id,
                                                item.quantity + 1,
                                              ),
                                            );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Subtotal
                              Text(
                                '${item.subtotal.toStringAsFixed(2)} TJS',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              // Remove button
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () {
                                  context.read<CartBloc>().add(
                                        CartItemRemoved(item.product.id),
                                      );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                if (cartState.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),

                  // Payment Method Selector
                  Text(
                    'Способ оплаты',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'cash',
                        icon: Icon(Icons.payments_outlined, size: 18),
                        label: Text('Наличные'),
                      ),
                      ButtonSegment(
                        value: 'card',
                        icon: Icon(Icons.credit_card_rounded, size: 18),
                        label: Text('Карта'),
                      ),
                      ButtonSegment(
                        value: 'transfer',
                        icon: Icon(Icons.account_balance_rounded, size: 18),
                        label: Text('Перевод'),
                      ),
                    ],
                    selected: {cartState.paymentMethod},
                    onSelectionChanged: (selected) {
                      context.read<CartBloc>().add(
                            CartPaymentMethodSelected(selected.first),
                          );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Total amount row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Итого к оплате:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${cartState.totalAmount.toStringAsFixed(2)} TJS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkout Submit button
                  BlocBuilder<CheckoutBloc, CheckoutState>(
                    builder: (context, checkoutState) {
                      final isLoading = checkoutState is CheckoutLoading;

                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<CheckoutBloc>().add(
                                      CheckoutSubmitted(
                                        items: cartState.items,
                                        paymentMethod: cartState.paymentMethod,
                                      ),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Оплатить ${cartState.totalAmount.toStringAsFixed(2)} TJS',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInsufficientStockDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.inventory_2_outlined,
          color: Colors.orange,
          size: 44,
        ),
        title: const Text('Недостаточно товара на складе'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}
