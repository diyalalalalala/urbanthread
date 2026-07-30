import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

import 'proximity_sensor_service.dart';

/// Android and iOS implementation, over the `proximity_sensor` plugin.
///
/// The plugin reports `1` when something is within the sensor's near
/// threshold and `0` when it is not — the sensor is binary on most handsets,
/// which is why this exposes a bool rather than a distance.
class MobileProximitySensorService implements ProximitySensorService {
  Stream<bool>? _onNear;

  bool get _isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  @override
  Future<bool> get isAvailable async {
    if (!_isSupportedPlatform) return false;
    try {
      return await ProximitySensor.isProximitySensorAvailable();
    } on Object {
      // A `MissingPluginException` where the channel was never registered, a
      // `PlatformException` on a device that has no such sensor. Both mean the
      // same thing to a caller, and neither is worth surfacing.
      return false;
    }
  }

  /// Built once and reused, so several guarded screens on display at the same
  /// time share a single native registration. The chain stays broadcast, so it
  /// can be listened to again after the last subscriber leaves — which is what
  /// happens every time the app returns to the foreground.
  @override
  Stream<bool> get onNear => _onNear ??= _listen();

  Stream<bool> _listen() {
    if (!_isSupportedPlatform) return const Stream<bool>.empty();

    return ProximitySensor.events
        .map((reading) => reading > 0)
        // The Android side throws from `onListen` when the handset has no
        // proximity sensor, which arrives here as a stream error. Swallowing
        // it degrades the feature to "never obscures" instead of taking the
        // screen down with it.
        .handleError((Object error) {
          assert(() {
            debugPrint('Proximity sensor unavailable: $error');
            return true;
          }());
        })
        // The sensor re-reports its current state on register, and some
        // handsets emit repeats while an object sits still. Only transitions
        // are interesting.
        .distinct();
  }
}

/// Called through the conditional import in `proximity_sensor_service.dart`.
ProximitySensorService createPlatformProximitySensorService() =>
    MobileProximitySensorService();
