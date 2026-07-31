import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;

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
