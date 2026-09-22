import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/analytics_period_selector.dart';
import '../widgets/pnl_chart_card.dart';
import '../widgets/pnl_metrics_grid.dart';
import '../widgets/rankings_section.dart';

/// Comprehensive Financial Dashboard and P&L Analytics screen for Business Owner.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: BlocConsumer<AnalyticsBloc, AnalyticsState>(
        listener: (context, state) {
          if (state is AnalyticsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFDC2626),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AnalyticsLoading && state.isFirstFetch) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            );
          }

          if (state is AnalyticsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        context.read<AnalyticsBloc>().add(
                              const AnalyticsFetchRequested(isRefresh: true),
                            );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AnalyticsLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF6366F1),
              backgroundColor: const Color(0xFF1E293B),
              onRefresh: () async {
                context.read<AnalyticsBloc>().add(
                      AnalyticsFetchRequested(
                        from: state.from,
                        to: state.to,
                        isRefresh: true,
                      ),
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    AnalyticsPeriodSelector(
                      selectedPeriod: state.periodType,
                      from: state.from,
                      to: state.to,
                      onPeriodSelected: (type, customFrom, customTo) {
                        context.read<AnalyticsBloc>().add(
                              AnalyticsPeriodChanged(
                                periodType: type,
                                customFrom: customFrom,
                                customTo: customTo,
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 16),

                    // P&L Metrics Grid
                    PnlMetricsGrid(summary: state.summary),
                    const SizedBox(height: 16),

                    // Visual Charts Card (Pie / Bar)
                    PnlChartCard(summary: state.summary),
                    const SizedBox(height: 16),

                    // Rankings Section (Top Products & Sellers)
                    RankingsSection(
                      topProducts: state.topProducts,
                      sellersRanking: state.sellersRanking,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
