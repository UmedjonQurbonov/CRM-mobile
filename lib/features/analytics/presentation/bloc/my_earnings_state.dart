import 'package:equatable/equatable.dart';
import '../../domain/entities/seller_earnings_entity.dart';
import 'analytics_event.dart';

abstract class MyEarningsState extends Equatable {
  const MyEarningsState();

  @override
  List<Object?> get props => [];
}

class MyEarningsInitial extends MyEarningsState {
  const MyEarningsInitial();
}

class MyEarningsLoading extends MyEarningsState {
  final bool isFirstFetch;

  const MyEarningsLoading({this.isFirstFetch = true});

  @override
  List<Object?> get props => [isFirstFetch];
}

class MyEarningsLoaded extends MyEarningsState {
  final SellerEarningsEntity earnings;
  final AnalyticsPeriodType periodType;
  final DateTime? from;
  final DateTime? to;

  const MyEarningsLoaded({
    required this.earnings,
    this.periodType = AnalyticsPeriodType.thisMonth,
    this.from,
    this.to,
  });

  MyEarningsLoaded copyWith({
    SellerEarningsEntity? earnings,
    AnalyticsPeriodType? periodType,
    DateTime? from,
    DateTime? to,
  }) {
    return MyEarningsLoaded(
      earnings: earnings ?? this.earnings,
      periodType: periodType ?? this.periodType,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  List<Object?> get props => [
        earnings,
        periodType,
        from,
        to,
      ];
}

class MyEarningsFailure extends MyEarningsState {
  final String message;

  const MyEarningsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
