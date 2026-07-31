import 'proximity_sensor_service_unsupported.dart'
    if (dart.library.io) 'proximity_sensor_service_mobile.dart';

abstract interface class ProximitySensorService {
  Future<bool> get isAvailable;

  Stream<bool> get onNear;
}

ProximitySensorService createProximitySensorService() =>
    createPlatformProximitySensorService();
