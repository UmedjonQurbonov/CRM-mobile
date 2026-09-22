import 'package:equatable/equatable.dart';

/// Base failure class for Clean Architecture domain layer.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-side error failure (4xx, 5xx, or business logic violations).
class ServerFailure extends Failure {
  final Map<String, dynamic>? details;

  const ServerFailure(
    super.message, {
    super.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

/// Authentication/authorization failure (401 / 403 / session expired).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.code});
}

/// Network connectivity failure (no internet, timeout, host unreachable).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Local cache / secure storage failure.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Unexpected or unknown failure.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
