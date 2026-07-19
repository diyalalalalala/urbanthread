import 'dart:async';

/// A one-way channel for "the session just ended, unexpectedly".
///
/// This exists to keep the dependency rule intact. The Dio interceptor has to
/// react to a 401, but core cannot import the authentication feature — that
/// would point a lower layer at a higher one. So core owns the *signal* and
/// the auth feature subscribes to it, inverting the dependency.
///
/// Only involuntary expiry travels through here. A deliberate sign-out is an
/// ordinary use case call and needs no broadcast.
class SessionEvents {
  final _controller = StreamController<void>.broadcast();

  /// Fires when a request came back 401 on a route that is not a credential
  /// check. The auth notifier listens and drops to signed-out, which the
  /// router turns into a redirect to login.
  Stream<void> get expired => _controller.stream;

  void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}
