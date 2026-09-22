import 'package:crm_mobile/features/sellers/data/models/create_seller_request_model.dart';
import 'package:crm_mobile/features/sellers/data/models/seller_model.dart';
import 'package:crm_mobile/features/sellers/data/models/update_commission_request_model.dart';
import 'package:crm_mobile/features/sellers/domain/entities/create_seller_params.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SellerModel JSON Parsing', () {
    test('parses UserDTO JSON correctly into SellerModel with Decimal commission', () {
      final jsonMap = {
        'id': 'seller-uuid-1',
        'name': 'Umedjon Qurbonov',
        'phone': '+992901111111',
        'role': 'seller',
        'commission_rate': '7.50',
      };

      final model = SellerModel.fromJson(jsonMap);

      expect(model.id, 'seller-uuid-1');
      expect(model.name, 'Umedjon Qurbonov');
      expect(model.phone, '+992901111111');
      expect(model.role, 'seller');
      expect(model.commissionRate, Decimal.parse('7.50'));
      expect(model.commissionFormatted, '7.50%');
    });

    test('serializes to JSON correctly', () {
      final model = SellerModel(
        id: 's-1',
        name: 'John Doe',
        phone: '+992900000000',
        role: 'seller',
        commissionRate: Decimal.parse('5.00'),
      );

      final json = model.toJson();

      expect(json['id'], 's-1');
      expect(json['name'], 'John Doe');
      expect(json['phone'], '+992900000000');
      expect(json['role'], 'seller');
      expect(json['commission_rate'], '5.00');
    });
  });

  group('CreateSellerRequestModel & UpdateCommissionRequestModel', () {
    test('CreateSellerRequestModel maps parameters to JSON numbers', () {
      final params = CreateSellerParams(
        name: 'New Seller',
        phone: '+992901234567',
        password: 'Password123!',
        commissionRate: Decimal.parse('6.50'),
      );

      final model = CreateSellerRequestModel.fromEntity(params);
      final json = model.toJson();

      expect(json['name'], 'New Seller');
      expect(json['phone'], '+992901234567');
      expect(json['password'], 'Password123!');
      expect(json['commission_rate'], 6.5);
    });

    test('UpdateCommissionRequestModel serializes commission rate to number', () {
      final model = UpdateCommissionRequestModel.fromDecimal(Decimal.parse('10.00'));
      final json = model.toJson();

      expect(json['commission_rate'], 10.0);
    });
  });
}
