import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/bloc/products_bloc.dart';
import '../../../products/presentation/bloc/products_event.dart';
import '../../../products/presentation/bloc/products_state.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_modal_sheet.dart';

/// Interactive Cashier POS Terminal Screen with quick product search,
/// direct QR camera scanning, real-time cart tally, and checkout modal.
class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // If ProductsBloc is already provided (e.g. tests), reuse it; else resolve from DI
    try {
      context.read<ProductsBloc>();
      return const _PosView();
    } catch (_) {
      return BlocProvider(
        create: (_) => sl<ProductsBloc>()..add(const ProductsFetchRequested()),
        child: const _PosView(),
      );
    }
  }
}

class _PosView extends StatefulWidget {
  const _PosView();

  @override
  State<_PosView> createState() => _PosViewState();
}

class _PosViewState extends State<_PosView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openScanner(BuildContext context) async {
    final scannedProduct = await context.push<ProductEntity>('/qr-scanner');
    if (scannedProduct != null && context.mounted) {
      context.read<CartBloc>().add(CartItemAdded(scannedProduct));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Товар добавлен в чек: ${scannedProduct.name}'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Кассовый Терминал (POS)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'История чеков',
            onPressed: () => context.push('/orders'),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Сканировать товар',
            onPressed: () => _openScanner(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildFloatingCartBar(context),
      body: Column(
        children: [
          // Search & Scanner Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withAlpha(50),
                ),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                context.read<ProductsBloc>().add(ProductsSearchChanged(query));
              },
              decoration: InputDecoration(
                hintText: 'Поиск товара по названию или SKU...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<ProductsBloc>()
                              .add(const ProductsSearchChanged(''));
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      tooltip: 'Сканер штрихкода',
                      onPressed: () => _openScanner(context),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    theme.colorScheme.surfaceContainerHighest.withAlpha(120),
              ),
            ),
          ),

          // Products Catalog
          Expanded(
            child: BlocListener<CartBloc, CartState>(
              listener: (context, cartState) {
                if (cartState.warningMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(cartState.warningMessage!),
                      backgroundColor: Colors.orange[800],
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading && state.isFirstFetch) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProductsFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ProductsBloc>().add(
                                    const ProductsFetchRequested(
                                      refresh: true,
                                    ),
                                  );
                            },
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    );
                  }

                  final products = state is ProductsLoaded
                      ? state.products
                      : <ProductEntity>[];

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 54,
                            color: Colors.grey.withAlpha(120),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Товары не найдены',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProductsBloc>().add(
                            const ProductsFetchRequested(refresh: true),
                          );
                    },
                    child: BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          itemCount: products.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final cartIndex = cartState.items.indexWhere(
                              (i) => i.product.id == product.id,
                            );
                            final inCartQty = cartIndex >= 0
                                ? cartState.items[cartIndex].quantity
                                : 0;

                            return _buildPosProductCard(
                              context,
                              product,
                              inCartQty,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosProductCard(
    BuildContext context,
    ProductEntity product,
    int inCartQty,
  ) {
    final theme = Theme.of(context);
    final isOutOfStock = product.stockQuantity <= 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: inCartQty > 0
              ? theme.colorScheme.primary
              : theme.dividerColor.withAlpha(50),
          width: inCartQty > 0 ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isOutOfStock
            ? null
            : () {
                context.read<CartBloc>().add(CartItemAdded(product));
              },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Product icon / status badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: inCartQty > 0
                      ? theme.colorScheme.primary.withAlpha(30)
                      : theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  inCartQty > 0
                      ? Icons.check_circle_outline_rounded
                      : Icons.inventory_2_outlined,
                  color: inCartQty > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
              const SizedBox(width: 14),

              // Title, SKU, and Stock
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${product.sku} • Остаток: ${product.stockQuantity} шт.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOutOfStock
                            ? Colors.red
                            : theme.colorScheme.onSurface.withAlpha(140),
                      ),
                    ),
                  ],
                ),
              ),

              // Price & In-Cart Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.sellingPrice.toStringAsFixed(2)} TJS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (inCartQty > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'В чеке: $inCartQty',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingCartBar(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        if (cartState.isEmpty) return const SizedBox.shrink();

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(80),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cartState.totalItems} шт. в чеке',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${cartState.totalAmount.toStringAsFixed(2)} TJS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => CartModalSheet.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'К оплате',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
