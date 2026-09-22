import 'package:crm_mobile/features/expenses/data/models/create_expense_request_model.dart';
import 'package:crm_mobile/features/expenses/data/models/expense_list_response_model.dart';
import 'package:crm_mobile/features/expenses/data/models/expense_response_model.dart';
import 'package:crm_mobile/features/expenses/domain/entities/create_expense_params.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseResponseModel JSON Parsing', () {
    test('parses valid ExpenseResponseDTO JSON with Decimal amount and DateTime', () {
      final jsonMap = {
        'id': 'exp-uuid-1',
        'amount': '450.00',
        'category': 'utilities',
        'comment': 'Monthly electricity bill for store',
        'expense_date': '2026-09-22',
        'created_by': 'user-owner-1',
        'created_at': '2026-09-22T10:00:00Z',
      };

      final model = ExpenseResponseModel.fromJson(jsonMap);

      expect(model.id, 'exp-uuid-1');
      expect(model.amount, Decimal.parse('450.00'));
      expect(model.category, 'utilities');
      expect(model.categoryLocalized, 'Коммунальные услуги');
      expect(model.comment, 'Monthly electricity bill for store');
      expect(model.expenseDate.year, 2026);
      expect(model.expenseDate.month, 9);
      expect(model.expenseDate.day, 22);
      expect(model.createdBy, 'user-owner-1');
      expect(model.createdAt, isNotNull);
    });

    test('parses numeric amount into Decimal gracefully', () {
      final jsonMap = {
        'id': 'exp-uuid-2',
        'amount': 1250.75,
        'category': 'rent',
        'comment': 'Store rent',
        'expense_date': '2026-09-01',
      };

      final model = ExpenseResponseModel.fromJson(jsonMap);

      expect(model.amount, Decimal.parse('1250.75'));
      expect(model.categoryLocalized, 'Аренда');
    });

    test('serializes to JSON correctly', () {
      final model = ExpenseResponseModel(
        id: 'exp-10',
        amount: Decimal.parse('300.50'),
        category: 'logistics',
        comment: 'Cargo delivery',
        expenseDate: DateTime(2026, 9, 20),
        createdBy: 'owner-id',
      );

      final json = model.toJson();

      expect(json['id'], 'exp-10');
      expect(json['amount'], '300.5');
      expect(json['category'], 'logistics');
      expect(json['comment'], 'Cargo delivery');
      expect(json['expense_date'], '2026-09-20');
      expect(json['created_by'], 'owner-id');
    });
  });

  group('ExpenseListResponseModel JSON Parsing', () {
    test('parses list response and calculates totalAmount in Decimal', () {
      final jsonMap = {
        'items': [
          {
            'id': 'exp-1',
            'amount': '150.00',
            'category': 'supplies',
            'comment': 'Thermal paper rolls',
            'expense_date': '2026-09-10',
          },
          {
            'id': 'exp-2',
            'amount': '350.25',
            'category': 'utilities',
            'comment': 'Water and internet',
            'expense_date': '2026-09-15',
          },
        ],
        'total': 5,
        'limit': 2,
        'offset': 0,
      };

      final listModel = ExpenseListResponseModel.fromJson(jsonMap);

      expect(listModel.items.length, 2);
      expect(listModel.total, 5);
      expect(listModel.limit, 2);
      expect(listModel.offset, 0);
      expect(listModel.hasMore, isTrue);
      // 150.00 + 350.25 = 500.25
      expect(listModel.totalAmount, Decimal.parse('500.25'));
    });
  });

  group('CreateExpenseRequestModel', () {
    test('formats from CreateExpenseParams correctly', () {
      final params = CreateExpenseParams(
        amount: Decimal.parse('850.00'),
        category: 'salary',
        comment: 'Advance payment',
        expenseDate: DateTime(2026, 9, 22),
      );

      final model = CreateExpenseRequestModel.fromEntity(params);
      final json = model.toJson();

      expect(json['amount'], '850');
      expect(json['category'], 'salary');
      expect(json['comment'], 'Advance payment');
      expect(json['expense_date'], '2026-09-22');
    });
  });
}
