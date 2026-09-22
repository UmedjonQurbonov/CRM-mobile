import 'dart:async';

/// Global authentication events emitted across the app.
enum AuthEvent {
  /// Emitted when silent token refresh fails or the session is invalidated.
  unauthenticated,

  /// Emitted when tokens are successfully refreshed.
  tokenRefreshed,
}

/// App-wide broadcast event bus for authentication lifecycle events.
class AuthEventBus {
  final StreamController<AuthEvent> _controller =
      StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get stream => _controller.stream;

  void emit(AuthEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
