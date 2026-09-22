import '../entities/product_entity.dart';
import '../entities/product_params.dart';

/// Contract for catalog, inventory, and QR lookup operations.
abstract class ProductRepository {
  /// Fetches products with pagination, debounced text search, and low-stock filter.
  Future<ProductListEntity> getProducts({
    String? search,
    bool? lowStock,
    int limit = 20,
    int offset = 0,
  });

  /// Looks up single product by its QR / barcode.
  Future<ProductEntity> getProductByQr(String qrCode);

  /// Creates a new product (Owner role only).
  Future<ProductEntity> createProduct(CreateProductParams params);

  /// Updates product details (Owner role only).
  Future<ProductEntity> updateProduct(String id, UpdateProductParams params);
}
