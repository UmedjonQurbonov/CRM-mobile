import 'package:crm_mobile/core/router/app_router.dart';
import 'package:crm_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sellerUser = UserEntity(
    id: 'seller-1',
    name: 'Cashier Seller',
    phone: '+992901111111',
    role: 'seller',
    commissionRate: Decimal.zero,
  );

  final ownerUser = UserEntity(
    id: 'owner-1',
    name: 'Admin Owner',
    phone: '+992900000000',
    role: 'owner',
    commissionRate: Decimal.zero,
  );

  group('AppRouter - RBAC Navigation Guards', () {
    group('Unauthenticated user', () {
      test('redirects to /login when attempting to access /pos', () {
        final redirect = AppRouter.evaluateRedirect(
          authState: const Unauthenticated(),
          matchedLocation: '/pos',
        );
        expect(redirect, '/login');
      });

      test('redirects to /login when attempting to access /dashboard', () {
        final redirect = AppRouter.evaluateRedirect(
          authState: const Unauthenticated(),
          matchedLocation: '/dashboard',
        );
        expect(redirect, '/login');
      });

      test('remains on /login when accessing /login', () {
        final redirect = AppRouter.evaluateRedirect(
          authState: const Unauthenticated(),
          matchedLocation: '/login',
        );
        expect(redirect, isNull);
      });
    });

    group('Authenticated Seller (RBAC)', () {
      test('redirects from /login to /pos', () {
        final redirect = AppRouter.evaluateRedirect(
          authState: Authenticated(sellerUser),
          matchedLocation: '/login',
        );
        expect(redirect, '/pos');
      });

      test('allows access to allowed seller routes', () {
        expect(
          AppRouter.evaluateRedirect(
            authState: Authenticated(sellerUser),
            matchedLocation: '/pos',
          ),
          isNull,
        );
        expect(
          AppRouter.evaluateRedirect(
            authState: Authenticated(sellerUser),
            matchedLocation: '/products',
          ),
          isNull,
        );
        expect(
          AppRouter.evaluateRedirect(
            authState: Authenticated(sellerUser),
            matchedLocation: '/my-earnings',
          ),
          isNull,
        );
      });

      test('blocks access to /dashboard and redirects back to /pos', () {
        final redirect = AppRouter.evaluateRedirect(
          authState: Authenticated(sellerUser),
          matchedLocation: '/dashboard',
        );
        expect(redirect, '/pos');
      });

      test('blocks access to /expenses and redirects back to /pos', () {
        final redirect = AppRouter.evaluateRedirect(
          authState: Authenticated(sellerUser),
          matchedLocation: '/expenses',
        );
        expect(redirect, '/pos');
      });

      test('blocks access to /sellers and redirects back to /pos', () {
        final redirect = AppRouter.evaluateRedirect(
          authState: Authenticated(sellerUser),
          matchedLocation: '/sellers',
        );
        expect(redirect, '/pos');
      });

      test('blocks access to /analytics and redirects back to /pos', () {
        final redirect = AppRouter.evaluateRedirect(
          authState: Authenticated(sellerUser),
          matchedLocation: '/analytics',
        );
        expect(redirect, '/pos');
      });
    });

    group('Authenticated Owner (Full Access)', () {
      test('redirects from /login to /dashboard', () {
        final redirect = AppRouter.evaluateRedirect(
          authState: Authenticated(ownerUser),
          matchedLocation: '/login',
        );
        expect(redirect, '/dashboard');
      });

      test('allows unrestricted access to all routes', () {
        final routes = [
          '/dashboard',
          '/pos',
          '/products',
          '/expenses',
          '/sellers',
          '/analytics',
          '/my-earnings',
        ];

        for (final route in routes) {
          final redirect = AppRouter.evaluateRedirect(
            authState: Authenticated(ownerUser),
            matchedLocation: route,
          );
          expect(redirect, isNull, reason: 'Owner should have access to $route');
        }
      });
    });
  });
}
