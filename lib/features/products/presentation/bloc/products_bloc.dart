import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/product_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

/// BLoC managing product catalog fetching, search, low-stock filter, and mutations.
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductRepository productRepository;
  Timer? _searchDebounceTimer;

  ProductsBloc({required this.productRepository})
      : super(const ProductsInitial()) {
    on<ProductsFetchRequested>(_onFetchRequested);
    on<ProductsSearchChanged>(_onSearchChanged);
    on<ProductsExecuteSearch>(_onExecuteSearch);
    on<ProductsLowStockToggled>(_onLowStockToggled);
    on<ProductCreateSubmitted>(_onCreateSubmitted);
    on<ProductUpdateSubmitted>(_onUpdateSubmitted);
  }

  Future<void> _onFetchRequested(
    ProductsFetchRequested event,
    Emitter<ProductsState> emit,
  ) async {
    final currentState = state;
    final isLoadMore = event.isLoadMore;

    String currentQuery = '';
    bool currentLowStock = false;
    int currentOffset = 0;

    if (currentState is ProductsLoaded) {
      currentQuery = currentState.searchQuery;
      currentLowStock = currentState.lowStockOnly;
      if (isLoadMore) {
        if (!currentState.hasMore || currentState.isLoadingMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
        currentOffset = currentState.offset + currentState.products.length;
      } else {
        if (!event.refresh) {
          emit(const ProductsLoading(isFirstFetch: false));
        }
      }
    } else if (!event.refresh) {
      emit(const ProductsLoading(isFirstFetch: true));
    }

    try {
      final result = await productRepository.getProducts(
        search: currentQuery.isNotEmpty ? currentQuery : null,
        lowStock: currentLowStock ? true : null,
        limit: 20,
        offset: currentOffset,
      );

      if (isLoadMore && currentState is ProductsLoaded) {
        final combined = List.of(currentState.products)..addAll(result.items);
        emit(
          currentState.copyWith(
            products: combined,
            total: result.total,
            offset: currentOffset,
            hasMore: result.hasMore,
            isLoadingMore: false,
          ),
        );
      } else {
        emit(
          ProductsLoaded(
            products: result.items,
            total: result.total,
            offset: 0,
            searchQuery: currentQuery,
            lowStockOnly: currentLowStock,
            hasMore: result.hasMore,
          ),
        );
      }
    } on Failure catch (f) {
      emit(ProductsFailure(f.message, code: f.code));
    } catch (e) {
      emit(ProductsFailure(e.toString()));
    }
  }

  void _onSearchChanged(
    ProductsSearchChanged event,
    Emitter<ProductsState> emit,
  ) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 350), () {
      add(ProductsExecuteSearch(event.query));
    });
  }

  Future<void> _onExecuteSearch(
    ProductsExecuteSearch event,
    Emitter<ProductsState> emit,
  ) async {
    bool currentLowStock = false;
    if (state is ProductsLoaded) {
      currentLowStock = (state as ProductsLoaded).lowStockOnly;
    }

    emit(const ProductsLoading(isFirstFetch: false));

    try {
      final result = await productRepository.getProducts(
        search: event.query.trim().isNotEmpty ? event.query.trim() : null,
        lowStock: currentLowStock ? true : null,
        limit: 20,
        offset: 0,
      );

      emit(
        ProductsLoaded(
          products: result.items,
          total: result.total,
          offset: 0,
          searchQuery: event.query,
          lowStockOnly: currentLowStock,
          hasMore: result.hasMore,
        ),
      );
    } on Failure catch (f) {
      emit(ProductsFailure(f.message, code: f.code));
    } catch (e) {
      emit(ProductsFailure(e.toString()));
    }
  }

  Future<void> _onLowStockToggled(
    ProductsLowStockToggled event,
    Emitter<ProductsState> emit,
  ) async {
    String currentQuery = '';
    bool newLowStock = true;

    if (state is ProductsLoaded) {
      final loaded = state as ProductsLoaded;
      currentQuery = loaded.searchQuery;
      newLowStock = !loaded.lowStockOnly;
    }

    emit(const ProductsLoading(isFirstFetch: false));

    try {
      final result = await productRepository.getProducts(
        search: currentQuery.isNotEmpty ? currentQuery : null,
        lowStock: newLowStock ? true : null,
        limit: 20,
        offset: 0,
      );

      emit(
        ProductsLoaded(
          products: result.items,
          total: result.total,
          offset: 0,
          searchQuery: currentQuery,
          lowStockOnly: newLowStock,
          hasMore: result.hasMore,
        ),
      );
    } on Failure catch (f) {
      emit(ProductsFailure(f.message, code: f.code));
    } catch (e) {
      emit(ProductsFailure(e.toString()));
    }
  }

  Future<void> _onCreateSubmitted(
    ProductCreateSubmitted event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading(isFirstFetch: false));
    try {
      final created = await productRepository.createProduct(event.params);
      emit(
        ProductActionSuccess(
          message: 'Товар "${created.name}" успешно добавлен',
          product: created,
        ),
      );
      add(const ProductsFetchRequested(refresh: true));
    } on Failure catch (f) {
      emit(ProductsFailure(f.message, code: f.code));
    } catch (e) {
      emit(ProductsFailure(e.toString()));
    }
  }

  Future<void> _onUpdateSubmitted(
    ProductUpdateSubmitted event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading(isFirstFetch: false));
    try {
      final updated = await productRepository.updateProduct(
        event.id,
        event.params,
      );
      emit(
        ProductActionSuccess(
          message: 'Товар "${updated.name}" обновлен',
          product: updated,
        ),
      );
      add(const ProductsFetchRequested(refresh: true));
    } on Failure catch (f) {
      emit(ProductsFailure(f.message, code: f.code));
    } catch (e) {
      emit(ProductsFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }
}
