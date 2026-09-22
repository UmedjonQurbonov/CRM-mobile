import 'package:equatable/equatable.dart';
import '../../domain/entities/product_params.dart';

/// Base event class for catalog and inventory management.
abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch catalog products (initial, refresh, or paginated next page).
class ProductsFetchRequested extends ProductsEvent {
  final bool refresh;
  final bool isLoadMore;

  const ProductsFetchRequested({
    this.refresh = false,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [refresh, isLoadMore];
}

/// User typed query into search bar.
class ProductsSearchChanged extends ProductsEvent {
  final String query;

  const ProductsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Internal debounced search event.
class ProductsExecuteSearch extends ProductsEvent {
  final String query;

  const ProductsExecuteSearch(this.query);

  @override
  List<Object?> get props => [query];
}

/// Toggle low stock alert filter.
class ProductsLowStockToggled extends ProductsEvent {
  const ProductsLowStockToggled();
}

/// Owner creates a new product.
class ProductCreateSubmitted extends ProductsEvent {
  final CreateProductParams params;

  const ProductCreateSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}

/// Owner updates existing product.
class ProductUpdateSubmitted extends ProductsEvent {
  final String id;
  final UpdateProductParams params;

  const ProductUpdateSubmitted({
    required this.id,
    required this.params,
  });

  @override
  List<Object?> get props => [id, params];
}
