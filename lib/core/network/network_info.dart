import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Answers "can we actually reach the internet right now?".
///
/// Two packages because they answer different questions and only the pair is
/// trustworthy. `connectivity_plus` reports the *interface* state — it says
/// "connected" for a Wi-Fi network behind a captive portal, or a mobile
/// connection with no data left. `internet_connection_checker_plus` performs
/// a real lookup. So the interface change is used as the cheap trigger, and
/// the reachability probe as the verdict.
abstract interface class NetworkInfo {
  /// True when a request has a genuine chance of succeeding.
  Future<bool> get isConnected;

  /// Emits on every transition, de-duplicated — subscribers see a value only
  /// when connectivity actually flips, not on every interface twitch.
  ///
  /// This is what drives the offline banner and the write-queue flush.
  Stream<bool> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({
    required Connectivity connectivity,
    required InternetConnection internetConnection,
  })  : _connectivity = connectivity,
        _internetConnection = internetConnection;

  final Connectivity _connectivity;
  final InternetConnection _internetConnection;

  @override
  Future<bool> get isConnected async {
    // Short-circuit on a definitively dead interface: no point paying for a
    // DNS round trip to learn what the OS already knows.
    final interfaces = await _connectivity.checkConnectivity();
    if (interfaces.every((result) => result == ConnectivityResult.none)) {
      return false;
    }
    return _internetConnection.hasInternetAccess;
  }

  @override
  Stream<bool> get onStatusChange {
    late StreamController<bool> controller;
    StreamSubscription<List<ConnectivityResult>>? subscription;
    bool? last;

    Future<void> emit() async {
      final connected = await isConnected;
      // Only surface real transitions. Android in particular fires several
      // interface events for a single network change, and re-emitting would
      // make the banner flicker and the sync queue run repeatedly.
      if (connected != last) {
        last = connected;
        if (!controller.isClosed) controller.add(connected);
      }
    }

    controller = StreamController<bool>.broadcast(
      onListen: () {
        unawaited(emit());
        subscription = _connectivity.onConnectivityChanged.listen(
          (_) => unawaited(emit()),
        );
      },
      onCancel: () async {
        await subscription?.cancel();
        subscription = null;
      },
    );

    return controller.stream;
  }
}
