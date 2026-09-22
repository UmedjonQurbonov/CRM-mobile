import 'package:equatable/equatable.dart';
import 'analytics_event.dart';

abstract class MyEarningsEvent extends Equatable {
  const MyEarningsEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to fetch or refresh caller seller's personal earnings.
class MyEarningsFetchRequested extends MyEarningsEvent {
  final DateTime? from;
  final DateTime? to;
  final bool isRefresh;

  const MyEarningsFetchRequested({
    this.from,
    this.to,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [from, to, isRefresh];
}

/// Dispatched when date filter period changes on MyEarningsScreen.
class MyEarningsPeriodChanged extends MyEarningsEvent {
  final AnalyticsPeriodType periodType;
  final DateTime? customFrom;
  final DateTime? customTo;

  const MyEarningsPeriodChanged({
    required this.periodType,
    this.customFrom,
    this.customTo,
  });

  @override
  List<Object?> get props => [periodType, customFrom, customTo];
}
