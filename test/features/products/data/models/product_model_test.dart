import 'package:crm_mobile/features/products/data/models/product_list_response_model.dart';
import 'package:crm_mobile/features/products/data/models/product_model.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel', () {
    final sampleJson = <String, dynamic>{
      'id': 'prod-uuid-1',
      'name': 'Samsung Galaxy S24',
      'sku': 'SAMSUNG-S24-128',
      'qr_code': '8806091234567',
      'cost_price': '850.50',
      'selling_price': '1150.00',
      'stock_quantity': 5,
      'min_stock_alert': 10,
      'is_low_stock': true,
      'is_active': true,
      'created_at': '2026-03-01T10:00:00Z',
      'updated_at': '2026-03-02T12:00:00Z',
    };

    test('fromJson parses full JSON with string Decimal prices correctly', () {
      final model = ProductModel.fromJson(sampleJson);

      expect(model.id, 'prod-uuid-1');
      expect(model.name, 'Samsung Galaxy S24');
      expect(model.sku, 'SAMSUNG-S24-128');
      expect(model.qrCode, '8806091234567');
      expect(model.costPrice, Decimal.parse('850.50'));
      expect(model.sellingPrice, Decimal.parse('1150.00'));
      expect(model.stockQuantity, 5);
      expect(model.minStockAlert, 10);
      expect(model.isLowStock, true);
      expect(model.isActive, true);
      expect(model.createdAt, DateTime.parse('2026-03-01T10:00:00Z'));
      expect(model.updatedAt, DateTime.parse('2026-03-02T12:00:00Z'));
    });

    test('fromJson parses numeric prices and computes isLowStock when flag is missing', () {
      final jsonWithNumbers = <String, dynamic>{
        'id': 'prod-uuid-2',
        'name': 'USB-C Cable',
        'cost_price': 15,
        'selling_price': 25.5,
        'stock_quantity': 3,
        'min_stock_alert': 5,
      };

      final model = ProductModel.fromJson(jsonWithNumbers);

      expect(model.costPrice, Decimal.parse('15'));
      expect(model.sellingPrice, Decimal.parse('25.5'));
      // Stock (3) <= minStockAlert (5) -> isLowStock = true
      expect(model.isLowStock, true);
    });

    test('isLowStock evaluates to false when stockQuantity exceeds minStockAlert', () {
      final json = <String, dynamic>{
        'id': 'prod-uuid-3',
        'name': 'Power Bank 20000mAh',
        'cost_price': '100',
        'selling_price': '150',
        'stock_quantity': 15,
        'min_stock_alert': 5,
      };

      final model = ProductModel.fromJson(json);
      expect(model.isLowStock, false);
    });

    test('toJson produces valid serializable map representation', () {
      final model = ProductModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], 'prod-uuid-1');
      expect(json['name'], 'Samsung Galaxy S24');
      expect(json['cost_price'], Decimal.parse('850.50').toString());
      expect(json['selling_price'], Decimal.parse('1150.00').toString());
      expect(json['stock_quantity'], 5);
      expect(json['is_low_stock'], true);
    });
  });

  group('ProductListResponseModel', () {
    test('fromJson parses items list and pagination metadata', () {
      final listJson = <String, dynamic>{
        'items': [
          {
            'id': 'prod-1',
            'name': 'Product 1',
            'cost_price': '10.00',
            'selling_price': '20.00',
            'stock_quantity': 50,
          },
          {
            'id': 'prod-2',
            'name': 'Product 2',
            'cost_price': '30.00',
            'selling_price': '45.00',
            'stock_quantity': 2,
            'min_stock_alert': 5,
          },
        ],
        'total': 45,
        'limit': 20,
        'offset': 0,
      };

      final listModel = ProductListResponseModel.fromJson(listJson);

      expect(listModel.items.length, 2);
      expect(listModel.total, 45);
      expect(listModel.limit, 20);
      expect(listModel.offset, 0);
      // offset (0) + items (2) < total (45) => hasMore = true
      expect(listModel.hasMore, true);
    });

    test('hasMore is false when all items are loaded', () {
      final listJson = <String, dynamic>{
        'items': [
          {
            'id': 'prod-1',
            'name': 'Product 1',
            'cost_price': '10.00',
            'selling_price': '20.00',
            'stock_quantity': 50,
          },
        ],
        'total': 1,
        'limit': 20,
        'offset': 0,
      };

      final listModel = ProductListResponseModel.fromJson(listJson);
      expect(listModel.hasMore, false);
    });
  });
}
