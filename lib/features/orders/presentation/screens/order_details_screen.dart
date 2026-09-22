import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

/// Screen displaying detailed items breakdown for an order and Owner refund action.
class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final OrderEntity? initialOrder;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final isOwner = authState is Authenticated && authState.user.isOwner;

    return BlocConsumer<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is OrderRefundSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange[800],
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is OrdersFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        // Find updated order if present in state, else fallback to initialOrder
        OrderEntity? order = initialOrder;
        if (state is OrdersLoaded) {
          final match = state.orders.where((o) => o.id == orderId);
          if (match.isNotEmpty) {
            order = match.first;
          }
        }

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Детали чека')),
            body: const Center(child: Text('Чек не найден')),
          );
        }

        final isRefunded = order.isRefunded;
        final shortId = order.id.length >= 8
            ? order.id.substring(0, 8).toUpperCase()
            : order.id;

        final dateStr = order.createdAt != null
            ? '${order.createdAt!.day.toString().padLeft(2, '0')}.${order.createdAt!.month.toString().padLeft(2, '0')}.${order.createdAt!.year} ${order.createdAt!.hour.toString().padLeft(2, '0')}:${order.createdAt!.minute.toString().padLeft(2, '0')}'
            : 'Не указана';

        String paymentMethodName;
        switch (order.paymentMethod) {
          case 'card':
            paymentMethodName = 'Банковская карта';
            break;
          case 'transfer':
            paymentMethodName = 'Банковский перевод';
            break;
          case 'cash':
          default:
            paymentMethodName = 'Наличные';
            break;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Чек #$shortId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          bottomNavigationBar: isOwner && !isRefunded
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmRefund(context, order!),
                      icon: const Icon(Icons.replay_rounded, color: Colors.red),
                      label: const Text(
                        'Оформить возврат (Owner)',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isRefunded
                      ? Colors.red.withAlpha(20)
                      : theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isRefunded
                        ? Colors.red.withAlpha(80)
                        : theme.dividerColor.withAlpha(40),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isRefunded ? 'ЧЕК ВОЗВРАЩЕН' : 'ЧЕК ОПЛАЧЕН',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isRefunded ? Colors.red : Colors.green[700],
                          ),
                        ),
                        Text(
                          paymentMethodName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Итого:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${order.totalAmount.toStringAsFixed(2)} TJS',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isRefunded
                                ? Colors.grey
                                : theme.colorScheme.primary,
                            decoration: isRefunded
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Дата: $dateStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Комиссия продавца: ${order.commissionEarned.toStringAsFixed(2)} TJS (${order.commissionRateSnapshot}%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(140),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Товары в чеке',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Items breakdown list
              ...order.items.map((item) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor.withAlpha(50)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} шт. × ${item.unitPrice.toStringAsFixed(2)} TJS',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(140),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.subtotal.toStringAsFixed(2)} TJS',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _confirmRefund(BuildContext context, OrderEntity order) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 44,
        ),
        title: const Text('Подтверждение возврата'),
        content: Text(
          'Вы действительно хотите оформить возврат по чеку #${order.id.substring(0, 8).toUpperCase()} на сумму ${order.totalAmount.toStringAsFixed(2)} TJS?\n\nТовары будут возвращены на склад.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<OrdersBloc>().add(OrderRefundRequested(order.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Оформить возврат'),
          ),
        ],
      ),
    );
  }
}
