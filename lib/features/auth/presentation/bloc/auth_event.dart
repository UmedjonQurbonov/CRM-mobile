import 'package:equatable/equatable.dart';

/// Base event class for authentication bloc.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on cold start to verify existing session.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Dispatched when user submits credentials in login form.
class AuthLoginRequested extends AuthEvent {
  final String phone;
  final String password;

  const AuthLoginRequested({
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [phone, password];
}

/// Dispatched when user initiates manual logout.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Dispatched when silent token refresh fails or session is revoked.
class AuthSessionExpired extends AuthEvent {
  final String? message;

  const AuthSessionExpired([this.message]);

  @override
  List<Object?> get props => [message];
}
