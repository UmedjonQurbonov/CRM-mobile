import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing a business operational expense.
class ExpenseEntity extends Equatable {
  final String id;
  final Decimal amount;
  final String category;
  final String comment;
  final DateTime expenseDate;
  final String? createdBy;
  final DateTime? createdAt;

  const ExpenseEntity({
    required this.id,
    required this.amount,
    required this.category,
    required this.comment,
    required this.expenseDate,
    this.createdBy,
    this.createdAt,
  });

  /// Human-friendly localized name for expense categories.
  String get categoryLocalized {
    switch (category.toLowerCase()) {
      case 'rent':
        return 'Аренда';
      case 'utilities':
        return 'Коммунальные услуги';
      case 'salary':
        return 'Зарплата персонала';
      case 'logistics':
        return 'Логистика и доставка';
      case 'marketing':
        return 'Реклама и маркетинг';
      case 'supplies':
        return 'Хоз. расходы и расходники';
      case 'other':
      default:
        return 'Прочие расходы';
    }
  }

  /// Appropriate icon for the expense category.
  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.storefront_rounded;
      case 'utilities':
        return Icons.bolt_rounded;
      case 'salary':
        return Icons.badge_rounded;
      case 'logistics':
        return Icons.local_shipping_rounded;
      case 'marketing':
        return Icons.campaign_rounded;
      case 'supplies':
        return Icons.inventory_2_rounded;
      case 'other':
      default:
        return Icons.receipt_rounded;
    }
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        category,
        comment,
        expenseDate,
        createdBy,
        createdAt,
      ];
}

/// Paginated list of operational expenses with computed totals.
class ExpenseListEntity extends Equatable {
  final List<ExpenseEntity> items;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  const ExpenseListEntity({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  /// Total sum of all expense amounts currently loaded.
  Decimal get totalAmount =>
      items.fold(Decimal.zero, (sum, item) => sum + item.amount);

  @override
  List<Object?> get props => [items, total, limit, offset, hasMore];
}
