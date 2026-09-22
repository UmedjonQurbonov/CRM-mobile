import 'package:crm_mobile/features/analytics/data/models/analytics_summary_model.dart';
import 'package:crm_mobile/features/analytics/data/models/seller_earnings_model.dart';
import 'package:crm_mobile/features/analytics/data/models/seller_ranking_model.dart';
import 'package:crm_mobile/features/analytics/data/models/top_product_model.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsSummaryModel', () {
    final validJson = {
      'revenue': '12500.00',
      'cost_of_goods_sold': '7500.00',
      'gross_profit': '5000.00',
      'total_expenses': '1200.00',
      'total_commissions': '850.00',
      'net_profit': '2950.00',
      'total_orders': 120,
      'period_from': '2026-09-01',
      'period_to': '2026-09-22',
    };

    test('should parse JSON into AnalyticsSummaryModel with exact Decimal fields', () {
      final model = AnalyticsSummaryModel.fromJson(validJson);

      expect(model.revenue, Decimal.parse('12500.00'));
      expect(model.costOfGoodsSold, Decimal.parse('7500.00'));
      expect(model.grossProfit, Decimal.parse('5000.00'));
      expect(model.totalExpenses, Decimal.parse('1200.00'));
      expect(model.totalCommissions, Decimal.parse('850.00'));
      expect(model.netProfit, Decimal.parse('2950.00'));
      expect(model.totalOrders, 120);
      expect(model.periodFrom, DateTime(2026, 9, 1));
      expect(model.periodTo, DateTime(2026, 9, 22));
      expect(model.isProfitable, isTrue);
    });

    test('should handle null or zero numbers gracefully', () {
      final model = AnalyticsSummaryModel.fromJson({});

      expect(model.revenue, Decimal.zero);
      expect(model.costOfGoodsSold, Decimal.zero);
      expect(model.grossProfit, Decimal.zero);
      expect(model.totalExpenses, Decimal.zero);
      expect(model.totalCommissions, Decimal.zero);
      expect(model.netProfit, Decimal.zero);
      expect(model.totalOrders, 0);
      expect(model.periodFrom, isNull);
      expect(model.periodTo, isNull);
      expect(model.isProfitable, isTrue);
    });

    test('toJson returns expected string representation', () {
      final model = AnalyticsSummaryModel.fromJson(validJson);
      final json = model.toJson();

      expect(json['revenue'], '12500');
      expect(json['total_orders'], 120);
      expect(json['period_from'], '2026-09-01');
    });
  });

  group('SellerRankingModel', () {
    final validJson = {
      'seller_id': '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
      'seller_name': 'Umedjon Qurbonov',
      'total_orders': 45,
      'total_revenue': '6500.00',
      'commission_earned': '552.50',
      'revenue_share_percentage': '52.00%',
    };

    test('should parse JSON correctly and calculate shareValue', () {
      final model = SellerRankingModel.fromJson(validJson);

      expect(model.sellerId, '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d');
      expect(model.sellerName, 'Umedjon Qurbonov');
      expect(model.totalOrders, 45);
      expect(model.totalRevenue, Decimal.parse('6500.00'));
      expect(model.commissionEarned, Decimal.parse('552.50'));
      expect(model.revenueSharePercentage, '52.00%');
      expect(model.shareValue, 52.0);
    });
  });

  group('TopProductModel', () {
    final validJson = {
      'product_id': '70cf0d01-fca2-45ff-bf86-99602ea12f39',
      'product_name': 'Classic White T-Shirt',
      'sku': 'TSHIRT-WHT-001',
      'total_quantity_sold': 85,
      'total_revenue': '12750.00',
    };

    test('should parse JSON correctly with Decimal revenue', () {
      final model = TopProductModel.fromJson(validJson);

      expect(model.productId, '70cf0d01-fca2-45ff-bf86-99602ea12f39');
      expect(model.productName, 'Classic White T-Shirt');
      expect(model.sku, 'TSHIRT-WHT-001');
      expect(model.totalQuantitySold, 85);
      expect(model.totalRevenue, Decimal.parse('12750.00'));
    });
  });

  group('SellerEarningsModel', () {
    final validJson = {
      'seller_id': '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
      'seller_name': 'Umedjon Qurbonov',
      'commission_rate': '8.50%',
      'total_sales_amount': '6500.00',
      'total_commission_earned': '552.50',
      'orders_count': 45,
      'period_from': '2026-09-01',
      'period_to': '2026-09-22',
    };

    test('should parse JSON correctly with Decimal totals', () {
      final model = SellerEarningsModel.fromJson(validJson);

      expect(model.sellerId, '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d');
      expect(model.sellerName, 'Umedjon Qurbonov');
      expect(model.commissionRate, '8.50%');
      expect(model.totalSalesAmount, Decimal.parse('6500.00'));
      expect(model.totalCommissionEarned, Decimal.parse('552.50'));
      expect(model.ordersCount, 45);
      expect(model.periodFrom, DateTime(2026, 9, 1));
      expect(model.periodTo, DateTime(2026, 9, 22));
    });
  });
}
