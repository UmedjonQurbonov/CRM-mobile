import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/analytics/presentation/screens/dashboard_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/pos_checkout/presentation/screens/pos_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/sellers/presentation/screens/my_earnings_screen.dart';
import '../../features/sellers/presentation/screens/sellers_screen.dart';
import '../presentation/main_shell.dart';

/// App router configuration with strict Role-Based Access Control (RBAC) guards.
class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter _router;

  AppRouter({required this.authBloc}) {
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) => evaluateRedirect(
        authState: authBloc.state,
        matchedLocation: state.matchedLocation,
      ),
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(
            location: state.matchedLocation,
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/pos',
              builder: (context, state) => const PosScreen(),
            ),
            GoRoute(
              path: '/products',
              builder: (context, state) => const ProductsScreen(),
            ),
            GoRoute(
              path: '/expenses',
              builder: (context, state) => const ExpensesScreen(),
            ),
            GoRoute(
              path: '/sellers',
              builder: (context, state) => const SellersScreen(),
            ),
            GoRoute(
              path: '/my-earnings',
              builder: (context, state) => const MyEarningsScreen(),
            ),
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  GoRouter get router => _router;

  /// Pure, testable routing and RBAC evaluation.
  static String? evaluateRedirect({
    required AuthState authState,
    required String matchedLocation,
  }) {
    final isLoggingIn = matchedLocation == '/login';

    // 1. If unauthenticated, redirect to login
    if (authState is Unauthenticated) {
      return isLoggingIn ? null : '/login';
    }

    // 2. If authenticated, route according to role
    if (authState is Authenticated) {
      final user = authState.user;

      // If currently on login page, redirect to role home
      if (isLoggingIn) {
        return user.isOwner ? '/dashboard' : '/pos';
      }

      // RBAC: Sellers cannot access owner-only routes
      const ownerOnlyPrefixes = [
        '/expenses',
        '/sellers',
        '/analytics',
        '/dashboard',
      ];
      final isOwnerRoute =
          ownerOnlyPrefixes.any((prefix) => matchedLocation.startsWith(prefix));

      if (isOwnerRoute && !user.isOwner) {
        return '/pos';
      }

      return null; // Allowed
    }

    // AuthInitial / AuthLoading: stay on current location
    return null;
  }
}

/// Utility adapting a Dart Stream to [ChangeNotifier] for GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
