import 'package:crm_mobile/features/auth/data/models/user_model.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    test('parses from backend OpenAPI JSON for Owner', () {
      final json = {
        'id': 'a43c2c77-4cf7-4f81-9b16-560ef71c9b68',
        'name': 'Admin Owner',
        'phone': '+992900000000',
        'role': 'owner',
        'commission_rate': '0.00',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'a43c2c77-4cf7-4f81-9b16-560ef71c9b68');
      expect(user.name, 'Admin Owner');
      expect(user.phone, '+992900000000');
      expect(user.role, 'owner');
      expect(user.isOwner, isTrue);
      expect(user.isSeller, isFalse);
      expect(user.commissionRate, Decimal.zero);
    });

    test('parses from backend OpenAPI JSON for Seller with commission percentage', () {
      final json = {
        'id': '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
        'name': 'Cashier User',
        'phone': '+992901111111',
        'role': 'seller',
        'commission_rate': '7.50%',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d');
      expect(user.role, 'seller');
      expect(user.isSeller, isTrue);
      expect(user.isOwner, isFalse);
      expect(user.commissionRate, Decimal.parse('7.50'));
    });

    test('serializes to JSON correctly', () {
      final user = UserModel(
        id: '123',
        name: 'Test',
        phone: '+992900000000',
        role: 'seller',
        commissionRate: Decimal.parse('5.0'),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test');
      expect(json['role'], 'seller');
      expect(json['commission_rate'], '5');
    });

    test('toEntity converts to UserEntity with matching properties', () {
      final user = UserModel(
        id: '123',
        name: 'Test',
        phone: '+992900000000',
        role: 'owner',
        commissionRate: Decimal.zero,
      );

      final entity = user.toEntity();

      expect(entity.id, user.id);
      expect(entity.name, user.name);
      expect(entity.isOwner, isTrue);
      expect(entity.isSeller, isFalse);
    });
  });
}
