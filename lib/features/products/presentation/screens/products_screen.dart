import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';
import '../widgets/product_form_sheet.dart';

/// Screen displaying the product catalog, stock counts, search, low-stock filter,
/// and management actions for Owner.
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse existing BLoC if provided (e.g. in widget tests), else resolve from DI
    try {
      context.read<ProductsBloc>();
      return const _ProductsView();
    } catch (_) {
      return BlocProvider(
        create: (_) => sl<ProductsBloc>()..add(const ProductsFetchRequested()),
        child: const _ProductsView(),
      );
    }
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductsBloc>().add(
            const ProductsFetchRequested(isLoadMore: true),
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
    final authState = context.watch<AuthBloc>().state;
    final isOwner = authState is Authenticated && authState.user.isOwner;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Номенклатура и Склад',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Сканировать QR / штрихкод',
            onPressed: () => context.push('/qr-scanner'),
          ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const ProductFormSheet(),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Добавить товар'),
            )
          : null,
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ProductsFailure) {
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
          return Column(
            children: [
              // Search & Filter header
              _buildSearchAndFilters(context, state),

              // Product Content
              Expanded(
                child: _buildContent(context, state, isOwner),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ProductsState state) {
    final theme = Theme.of(context);
    final isLowStockActive =
        state is ProductsLoaded && state.lowStockOnly;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withAlpha(50),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (query) {
              context.read<ProductsBloc>().add(ProductsSearchChanged(query));
            },
            decoration: InputDecoration(
              hintText: 'Поиск по названию или SKU...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<ProductsBloc>()
                            .add(const ProductsSearchChanged(''));
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
            ),
          ),
          const SizedBox(height: 8),

          // Filter Chips Row
          Row(
            children: [
              FilterChip(
                selected: isLowStockActive,
                onSelected: (_) {
                  context
                      .read<ProductsBloc>()
                      .add(const ProductsLowStockToggled());
                },
                avatar: Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: isLowStockActive ? Colors.orange[800] : Colors.grey,
                ),
                label: const Text('Заканчивающиеся'),
                selectedColor: Colors.orange.withAlpha(40),
                checkmarkColor: Colors.orange[800],
              ),
              const Spacer(),
              if (state is ProductsLoaded)
                Text(
                  'Всего: ${state.total}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProductsState state,
    bool isOwner,
  ) {
    if (state is ProductsLoading && state.isFirstFetch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductsFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки каталога',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProductsBloc>().add(
                        const ProductsFetchRequested(refresh: true),
                      );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final products = state is ProductsLoaded
        ? state.products
        : <ProductEntity>[];

    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<ProductsBloc>().add(
                const ProductsFetchRequested(refresh: true),
              );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey.withAlpha(150),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Товары не найдены',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Попробуйте изменить поисковый запрос или фильтры',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isLoadingMore =
        state is ProductsLoaded && state.isLoadingMore;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProductsBloc>().add(
              const ProductsFetchRequested(refresh: true),
            );
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: products.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          final product = products[index];
          return _buildProductCard(context, product, isOwner);
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductEntity product,
    bool isOwner,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: product.isLowStock
              ? Colors.orange.withAlpha(120)
              : theme.dividerColor.withAlpha(50),
          width: product.isLowStock ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // Tap to edit only available for Owner
        onTap: isOwner
            ? () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ProductFormSheet(
                    initialProduct: product,
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name & Stock Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SKU: ${product.sku}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(140),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Stock Quantity Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.isLowStock
                          ? Colors.orange.withAlpha(35)
                          : Colors.green.withAlpha(35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (product.isLowStock) ...[
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '${product.stockQuantity} шт.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: product.isLowStock
                                ? Colors.deepOrange
                                : Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Pricing Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Selling Price (ALWAYS visible for both Seller and Owner)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Цена продажи',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${product.sellingPrice.toStringAsFixed(2)} TJS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Cost Price: Strictly Owner ONLY! Completely hidden for Seller.
                  if (isOwner)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Себестоимость',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(140),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withAlpha(100),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.costPrice.toStringAsFixed(2)} TJS',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                        ),
                      ],
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
