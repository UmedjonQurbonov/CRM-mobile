import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/auth_event_bus.dart' as bus;
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC managing authentication state and session lifecycle.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final bus.AuthEventBus authEventBus;
  late final StreamSubscription<bus.AuthEvent> _authEventSubscription;

  AuthBloc({
    required this.authRepository,
    required this.authEventBus,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthSessionExpired>(_onAuthSessionExpired);

    // Reactively receive network-level 401 unauthenticated events
    _authEventSubscription = authEventBus.stream.listen((event) {
      if (event == bus.AuthEvent.unauthenticated) {
        add(const AuthSessionExpired());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.checkAuthStatus();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.login(
        phone: event.phone,
        password: event.password,
      );
      emit(Authenticated(user));
    } on Failure catch (failure) {
      emit(
        Unauthenticated(
          errorMessage: _localizeErrorMessage(failure.code, failure.message),
          errorCode: failure.code,
        ),
      );
    } catch (e) {
      emit(
        Unauthenticated(
          errorMessage: e.toString(),
          errorCode: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.logout();
    } finally {
      emit(const Unauthenticated());
    }
  }

  void _onAuthSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) {
    emit(
      Unauthenticated(
        errorMessage: event.message ??
            'Сессия завершена. Пожалуйста, выполните вход повторно.',
        errorCode: 'SESSION_EXPIRED',
      ),
    );
  }

  /// Maps RFC 7807 error codes to clear, localized user messages.
  static String _localizeErrorMessage(String? code, String fallbackMessage) {
    return switch (code) {
      'INVALID_CREDENTIALS' => 'Неверный номер телефона или пароль.',
      'UNAUTHORIZED' => 'Не авторизован. Пожалуйста, выполните вход.',
      'FORBIDDEN' => 'У вас нет прав для выполнения этой операции.',
      'NO_INTERNET' => 'Отсутствует связь с сервером. Проверьте интернет.',
      'CONNECTION_TIMEOUT' => 'Превышено время ожидания ответа сервера.',
      'RECEIVE_TIMEOUT' => 'Сервер не отвечает вовремя. Попробуйте снова.',
      'USER_NOT_FOUND' => 'Пользователь с таким номером не найден.',
      _ => fallbackMessage.isNotEmpty
          ? fallbackMessage
          : 'Произошла непредвиденная ошибка.',
    };
  }

  @override
  Future<void> close() {
    _authEventSubscription.cancel();
    return super.close();
  }
}
