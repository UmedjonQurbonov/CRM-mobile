import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/seller_entity.dart';
import '../bloc/sellers_bloc.dart';
import '../bloc/sellers_event.dart';
import '../bloc/sellers_state.dart';
import '../widgets/create_seller_sheet.dart';
import '../widgets/update_commission_sheet.dart';

/// Screen for managing staff cashiers and commissions (Owner only).
class SellersScreen extends StatelessWidget {
  const SellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<SellersBloc>();
      return const _SellersView();
    } catch (_) {
      return BlocProvider(
        create: (_) => sl<SellersBloc>()..add(const SellersFetchRequested()),
        child: const _SellersView(),
      );
    }
  }
}

class _SellersView extends StatelessWidget {
  const _SellersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Управление Продавцами',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreateSellerSheet.show(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Новый продавец'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SellersBloc, SellersState>(
        listener: (context, state) {
          if (state is SellersLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is SellersFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SellersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SellersFailure && state is! SellersLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 54, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SellersBloc>().add(
                          const SellersFetchRequested(refresh: true),
                        ),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final sellers = state is SellersLoaded ? state.sellers : <SellerEntity>[];

          if (sellers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: Colors.grey.withAlpha(120),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Список продавцов пуст',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Нажмите "+ Новый продавец", чтобы добавить сотрудника',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SellersBloc>().add(
                    const SellersFetchRequested(refresh: true),
                  );
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: sellers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final seller = sellers[index];
                return _buildSellerCard(context, seller);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, SellerEntity seller) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withAlpha(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.withAlpha(30),
              child: Text(
                seller.name.isNotEmpty ? seller.name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seller.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withAlpha(140),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        seller.phone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Commission Badge & Edit button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withAlpha(100)),
                  ),
                  child: Text(
                    seller.commissionFormatted,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => UpdateCommissionSheet.show(context, seller),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Изменить',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
