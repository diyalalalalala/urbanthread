import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

import 'proximity_sensor_service.dart';

class MobileProximitySensorService implements ProximitySensorService {
  Stream<bool>? _onNear;

  bool get _isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  @override
  Future<bool> get isAvailable async {
    if (!_isSupportedPlatform) return false;
    try {
      return await ProximitySensor.isProximitySensorAvailable();
    } on Object {
      return false;
    }
  }

  @override
  Stream<bool> get onNear => _onNear ??= _listen();

  Stream<bool> _listen() {
    if (!_isSupportedPlatform) return const Stream<bool>.empty();

    return ProximitySensor.events
        .map((reading) => reading > 0)
        .handleError((Object error) {
          assert(() {
            debugPrint('Proximity sensor unavailable: $error');
            return true;
          }());
        })
        .distinct();
  }
}

ProximitySensorService createPlatformProximitySensorService() =>
    MobileProximitySensorService();
