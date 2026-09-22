import 'package:bloc_test/bloc_test.dart';
import 'package:crm_mobile/core/errors/failures.dart';
import 'package:crm_mobile/core/network/auth_event_bus.dart' as bus;
import 'package:crm_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:crm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:crm_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late bus.AuthEventBus authEventBus;

  final testUser = UserEntity(
    id: 'user-id-1',
    name: 'Admin Owner',
    phone: '+992900000000',
    role: 'owner',
    commissionRate: Decimal.zero,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authEventBus = bus.AuthEventBus();
  });

  tearDown(() {
    authEventBus.dispose();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final bloc = AuthBloc(
        authRepository: mockAuthRepository,
        authEventBus: authEventBus,
      );
      expect(bloc.state, const AuthInitial());
      bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when AuthCheckRequested finds active session',
      build: () {
        when(() => mockAuthRepository.checkAuthStatus())
            .thenAnswer((_) async => testUser);
        return AuthBloc(
          authRepository: mockAuthRepository,
          authEventBus: authEventBus,
        );
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        Authenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when AuthCheckRequested finds no session',
      build: () {
        when(() => mockAuthRepository.checkAuthStatus())
            .thenAnswer((_) async => null);
        return AuthBloc(
          authRepository: mockAuthRepository,
          authEventBus: authEventBus,
        );
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful AuthLoginRequested',
      build: () {
        when(
          () => mockAuthRepository.login(
            phone: '+992900000000',
            password: 'CorrectPassword',
          ),
        ).thenAnswer((_) async => testUser);
        return AuthBloc(
          authRepository: mockAuthRepository,
          authEventBus: authEventBus,
        );
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          phone: '+992900000000',
          password: 'CorrectPassword',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        Authenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] with localized message on INVALID_CREDENTIALS',
      build: () {
        when(
          () => mockAuthRepository.login(
            phone: '+992900000000',
            password: 'WrongPassword',
          ),
        ).thenThrow(
          const ServerFailure(
            'Invalid phone or password',
            code: 'INVALID_CREDENTIALS',
          ),
        );
        return AuthBloc(
          authRepository: mockAuthRepository,
          authEventBus: authEventBus,
        );
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          phone: '+992900000000',
          password: 'WrongPassword',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(
          errorMessage: 'Неверный номер телефона или пароль.',
          errorCode: 'INVALID_CREDENTIALS',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on AuthLogoutRequested',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(
          authRepository: mockAuthRepository,
          authEventBus: authEventBus,
        );
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    test('automatically transitions to Unauthenticated when AuthEventBus emits unauthenticated', () async {
      when(() => mockAuthRepository.checkAuthStatus())
          .thenAnswer((_) async => testUser);

      final bloc = AuthBloc(
        authRepository: mockAuthRepository,
        authEventBus: authEventBus,
      );

      // Transition to Authenticated first
      bloc.add(const AuthCheckRequested());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          Authenticated(testUser),
        ]),
      );

      // Emit unauthenticated event from network layer
      authEventBus.emit(bus.AuthEvent.unauthenticated);

      await expectLater(
        bloc.stream,
        emits(isA<Unauthenticated>().having(
          (u) => u.errorCode,
          'errorCode',
          'SESSION_EXPIRED',
        )),
      );

      await bloc.close();
    });
  });
}
