import 'package:crm_mobile/features/orders/data/models/order_item_response_model.dart';
import 'package:crm_mobile/features/orders/data/models/order_list_response_model.dart';
import 'package:crm_mobile/features/orders/data/models/order_response_model.dart';
import 'package:crm_mobile/features/pos_checkout/data/models/checkout_request_model.dart';
import 'package:crm_mobile/features/pos_checkout/domain/entities/cart_item_entity.dart';
import 'package:crm_mobile/features/products/domain/entities/product_entity.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderItemResponseModel', () {
    test('fromJson parses string decimal prices and quantities', () {
      final json = <String, dynamic>{
        'id': 'item-1',
        'product_id': 'prod-100',
        'product_name': 'AirPods Pro',
        'quantity': 2,
        'unit_price': '1250.50',
        'subtotal': '2501.00',
      };

      final model = OrderItemResponseModel.fromJson(json);

      expect(model.id, 'item-1');
      expect(model.productId, 'prod-100');
      expect(model.productName, 'AirPods Pro');
      expect(model.quantity, 2);
      expect(model.unitPrice, Decimal.parse('1250.50'));
      expect(model.subtotal, Decimal.parse('2501.00'));

      final entity = model.toEntity();
      expect(entity.id, model.id);
      expect(entity.unitPrice, model.unitPrice);
      expect(entity.subtotal, model.subtotal);
    });
  });

  group('OrderResponseModel', () {
    test('fromJson parses full order with commission and items', () {
      final json = <String, dynamic>{
        'id': 'order-uuid-1',
        'seller_id': 'seller-uuid-1',
        'total_amount': '2501.00',
        'commission_rate_snapshot': '5.00',
        'commission_earned': '125.05',
        'payment_method': 'card',
        'status': 'completed',
        'items': [
          {
            'id': 'item-1',
            'product_id': 'prod-100',
            'product_name': 'AirPods Pro',
            'quantity': 2,
            'unit_price': '1250.50',
            'subtotal': '2501.00',
          },
        ],
        'created_at': '2026-03-10T14:30:00Z',
        'updated_at': '2026-03-10T14:30:00Z',
      };

      final model = OrderResponseModel.fromJson(json);

      expect(model.id, 'order-uuid-1');
      expect(model.sellerId, 'seller-uuid-1');
      expect(model.totalAmount, Decimal.parse('2501.00'));
      expect(model.commissionRateSnapshot, Decimal.parse('5.00'));
      expect(model.commissionEarned, Decimal.parse('125.05'));
      expect(model.paymentMethod, 'card');
      expect(model.status, 'completed');
      expect(model.items.length, 1);
      expect(model.items.first.productName, 'AirPods Pro');

      final entity = model.toEntity();
      expect(entity.isCompleted, isTrue);
      expect(entity.isRefunded, isFalse);
    });
  });

  group('OrderListResponseModel', () {
    test('fromJson parses list and hasMore pagination calculation', () {
      final json = <String, dynamic>{
        'items': [
          {
            'id': 'order-1',
            'seller_id': 'seller-1',
            'total_amount': '100.00',
            'commission_rate_snapshot': '5.00',
            'commission_earned': '5.00',
            'payment_method': 'cash',
            'status': 'completed',
            'items': [],
          },
        ],
        'total': 10,
        'limit': 20,
        'offset': 0,
      };

      final listModel = OrderListResponseModel.fromJson(json);

      expect(listModel.items.length, 1);
      expect(listModel.total, 10);
      expect(listModel.hasMore, isTrue);
    });
  });

  group('CheckoutRequestModel', () {
    test('fromEntities creates valid request payload', () {
      final product = ProductEntity(
        id: 'prod-42',
        name: 'iPhone 15 Case',
        sku: 'CASE-15',
        qrCode: '123456789',
        costPrice: Decimal.parse('20.00'),
        sellingPrice: Decimal.parse('50.00'),
        stockQuantity: 10,
        minStockAlert: 2,
        isLowStock: false,
        isActive: true,
      );

      final cartItem = CartItemEntity(product: product, quantity: 3);

      final request = CheckoutRequestModel.fromEntities(
        items: [cartItem],
        paymentMethod: 'cash',
      );

      final json = request.toJson();
      expect(json['payment_method'], 'cash');
      final items = json['items'] as List<dynamic>;
      expect(items.length, 1);
      expect(items.first['product_id'], 'prod-42');
      expect(items.first['quantity'], 3);
    });
  });
}
