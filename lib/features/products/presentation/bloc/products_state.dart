import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

/// Base state for products bloc.
abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

/// Loading state for initial load or full-screen refresh.
class ProductsLoading extends ProductsState {
  final bool isFirstFetch;

  const ProductsLoading({this.isFirstFetch = true});

  @override
  List<Object?> get props => [isFirstFetch];
}

/// Successfully loaded catalog with pagination and active filters.
class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;
  final int total;
  final int offset;
  final int limit;
  final String searchQuery;
  final bool lowStockOnly;
  final bool hasMore;
  final bool isLoadingMore;

  const ProductsLoaded({
    required this.products,
    required this.total,
    required this.offset,
    this.limit = 20,
    this.searchQuery = '',
    this.lowStockOnly = false,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  ProductsLoaded copyWith({
    List<ProductEntity>? products,
    int? total,
    int? offset,
    int? limit,
    String? searchQuery,
    bool? lowStockOnly,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      searchQuery: searchQuery ?? this.searchQuery,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        products,
        total,
        offset,
        limit,
        searchQuery,
        lowStockOnly,
        hasMore,
        isLoadingMore,
      ];
}

/// Error state when network or business failure occurs.
class ProductsFailure extends ProductsState {
  final String message;
  final String? code;

  const ProductsFailure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Product created or updated successfully notification state.
class ProductActionSuccess extends ProductsState {
  final String message;
  final ProductEntity product;

  const ProductActionSuccess({
    required this.message,
    required this.product,
  });

  @override
  List<Object?> get props => [message, product];
}
