import 'package:equatable/equatable.dart';

enum AnalyticsPeriodType {
  today,
  thisMonth,
  custom,
}

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load or reload analytics with optional explicit date filters.
class AnalyticsFetchRequested extends AnalyticsEvent {
  final DateTime? from;
  final DateTime? to;
  final bool isRefresh;

  const AnalyticsFetchRequested({
    this.from,
    this.to,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [from, to, isRefresh];
}

/// Dispatched when the user switches periods (Today, This Month, Custom).
class AnalyticsPeriodChanged extends AnalyticsEvent {
  final AnalyticsPeriodType periodType;
  final DateTime? customFrom;
  final DateTime? customTo;

  const AnalyticsPeriodChanged({
    required this.periodType,
    this.customFrom,
    this.customTo,
  });

  @override
  List<Object?> get props => [periodType, customFrom, customTo];
}
