import 'proximity_sensor_service.dart';

/// The implementation used wherever there is no proximity sensor to read:
/// web, desktop, and anything else without `dart:io`.
///
/// It answers "unavailable" and never emits, which is exactly what the guard
/// widgets treat as "show the content normally". Nothing has to branch on
/// platform above this point.
class UnsupportedProximitySensorService implements ProximitySensorService {
  const UnsupportedProximitySensorService();

  @override
  Future<bool> get isAvailable async => false;

  @override
  Stream<bool> get onNear => const Stream<bool>.empty();
}

/// Called through the conditional import in `proximity_sensor_service.dart`.
ProximitySensorService createPlatformProximitySensorService() =>
    const UnsupportedProximitySensorService();
