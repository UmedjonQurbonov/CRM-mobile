import 'package:decimal/decimal.dart';
import '../entities/create_seller_params.dart';
import '../entities/seller_entity.dart';

/// Contract for managing cashier staff and their sales commissions.
abstract interface class SellersRepository {
  /// Returns a list of all active sellers.
  Future<List<SellerEntity>> getSellers();

  /// Registers a new seller account.
  Future<SellerEntity> createSeller(CreateSellerParams params);

  /// Updates the commission rate for an existing seller.
  Future<void> updateCommission(String sellerId, Decimal newRate);
}
