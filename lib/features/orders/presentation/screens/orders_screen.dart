import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

/// Screen displaying sales order receipts history with status filter and pagination.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<OrdersBloc>();
      return const _OrdersView();
    } catch (_) {
      return BlocProvider(
        create: (_) => sl<OrdersBloc>()..add(const OrdersFetchRequested()),
        child: const _OrdersView(),
      );
    }
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<OrdersBloc>().add(
            const OrdersFetchRequested(isLoadMore: true),
          );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'История Чеков',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrderRefundSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange[800],
                behavior: SnackBarBehavior.floating,
              ),
            );
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
          final activeStatus =
              state is OrdersLoaded ? state.statusFilter : null;

          return Column(
            children: [
              // Filter chips row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withAlpha(50),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    FilterChip(
                      selected: activeStatus == null,
                      onSelected: (_) {
                        context
                            .read<OrdersBloc>()
                            .add(const OrderStatusFilterChanged(null));
                      },
                      label: const Text('Все чеки'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: activeStatus == 'completed',
                      onSelected: (_) {
                        context
                            .read<OrdersBloc>()
                            .add(const OrderStatusFilterChanged('completed'));
                      },
                      label: const Text('Оплаченные'),
                      avatar: const Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: activeStatus == 'refunded',
                      onSelected: (_) {
                        context
                            .read<OrdersBloc>()
                            .add(const OrderStatusFilterChanged('refunded'));
                      },
                      label: const Text('Возвраты'),
                      avatar: const Icon(Icons.replay_rounded,
                          size: 16, color: Colors.orange),
                    ),
                  ],
                ),
              ),

              // Orders List
              Expanded(
                child: _buildOrdersList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, OrdersState state) {
    if (state is OrdersLoading && state.isFirstFetch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is OrdersFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(state.message, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context
                    .read<OrdersBloc>()
                    .add(const OrdersFetchRequested(refresh: true));
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final orders = state is OrdersLoaded ? state.orders : <OrderEntity>[];

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 54,
              color: Colors.grey.withAlpha(120),
            ),
            const SizedBox(height: 12),
            const Text(
              'Чеков не найдено',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final isLoadingMore = state is OrdersLoaded && state.isLoadingMore;

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<OrdersBloc>()
            .add(const OrdersFetchRequested(refresh: true));
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: orders.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= orders.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final order = orders[index];
          return _buildOrderCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    final shortId =
        order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id;

    final isRefunded = order.isRefunded;
    final dateStr = order.createdAt != null
        ? '${order.createdAt!.day.toString().padLeft(2, '0')}.${order.createdAt!.month.toString().padLeft(2, '0')}.${order.createdAt!.year} ${order.createdAt!.hour.toString().padLeft(2, '0')}:${order.createdAt!.minute.toString().padLeft(2, '0')}'
        : 'Не указана';

    String paymentMethodName;
    switch (order.paymentMethod) {
      case 'card':
        paymentMethodName = 'Карта';
        break;
      case 'transfer':
        paymentMethodName = 'Перевод';
        break;
      case 'cash':
      default:
        paymentMethodName = 'Наличные';
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withAlpha(50)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/orders/${order.id}', extra: order);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Чек #$shortId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isRefunded
                          ? Colors.red.withAlpha(30)
                          : Colors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isRefunded ? 'Возвращен' : 'Оплачен',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isRefunded ? Colors.red : Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date & Payment method
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                  Text(
                    paymentMethodName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Items count & Total amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Позиций: ${order.items.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                  ),
                  Text(
                    '${order.totalAmount.toStringAsFixed(2)} TJS',
                    style: TextStyle(
                      fontSize: 17,
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
            ],
          ),
        ),
      ),
    );
  }
}
