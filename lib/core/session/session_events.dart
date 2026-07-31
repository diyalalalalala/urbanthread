import 'dart:async';

class SessionEvents {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get expired => _controller.stream;

  void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}
