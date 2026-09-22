import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/analytics_repository.dart';
import 'analytics_event.dart';
import 'my_earnings_event.dart';
import 'my_earnings_state.dart';

/// BLoC managing seller personal earnings, commission statistics, and date filtering.
class MyEarningsBloc extends Bloc<MyEarningsEvent, MyEarningsState> {
  final AnalyticsRepository analyticsRepository;

  MyEarningsBloc({required this.analyticsRepository})
      : super(const MyEarningsInitial()) {
    on<MyEarningsFetchRequested>(_onFetchRequested);
    on<MyEarningsPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onFetchRequested(
    MyEarningsFetchRequested event,
    Emitter<MyEarningsState> emit,
  ) async {
    final currentState = state;
    DateTime? from = event.from;
    DateTime? to = event.to;
    AnalyticsPeriodType periodType = AnalyticsPeriodType.thisMonth;

    if (currentState is MyEarningsLoaded && from == null && to == null) {
      from = currentState.from;
      to = currentState.to;
      periodType = currentState.periodType;
    } else if (from == null && to == null) {
      final now = DateTime.now();
      from = DateTime(now.year, now.month, 1);
      to = DateTime(now.year, now.month, now.day);
      periodType = AnalyticsPeriodType.thisMonth;
    }

    if (!event.isRefresh) {
      emit(MyEarningsLoading(isFirstFetch: currentState is! MyEarningsLoaded));
    }

    try {
      final earnings = await analyticsRepository.getMyEarnings(
        from: from,
        to: to,
      );

      emit(
        MyEarningsLoaded(
          earnings: earnings,
          periodType: periodType,
          from: from,
          to: to,
        ),
      );
    } catch (e) {
      emit(MyEarningsFailure(e.toString()));
    }
  }

  Future<void> _onPeriodChanged(
    MyEarningsPeriodChanged event,
    Emitter<MyEarningsState> emit,
  ) async {
    DateTime? from;
    DateTime? to;
    final now = DateTime.now();

    switch (event.periodType) {
      case AnalyticsPeriodType.today:
        from = DateTime(now.year, now.month, now.day);
        to = DateTime(now.year, now.month, now.day);
        break;
      case AnalyticsPeriodType.thisMonth:
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month, now.day);
        break;
      case AnalyticsPeriodType.custom:
        from = event.customFrom;
        to = event.customTo;
        break;
    }

    emit(const MyEarningsLoading(isFirstFetch: false));

    try {
      final earnings = await analyticsRepository.getMyEarnings(
        from: from,
        to: to,
      );

      emit(
        MyEarningsLoaded(
          earnings: earnings,
          periodType: event.periodType,
          from: from,
          to: to,
        ),
      );
    } catch (e) {
      emit(MyEarningsFailure(e.toString()));
    }
  }
}
