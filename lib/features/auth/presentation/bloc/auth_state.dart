import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Base state class for authentication bloc.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state prior to session check or during splash screen.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading indicator state (logging in, refreshing, or logging out).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated with active session.
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not logged in, logged out, or session has expired.
class Unauthenticated extends AuthState {
  final String? errorMessage;
  final String? errorCode;

  const Unauthenticated({this.errorMessage, this.errorCode});

  @override
  List<Object?> get props => [errorMessage, errorCode];
}
