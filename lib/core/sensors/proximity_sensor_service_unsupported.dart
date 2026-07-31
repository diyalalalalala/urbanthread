import 'proximity_sensor_service.dart';

class UnsupportedProximitySensorService implements ProximitySensorService {
  const UnsupportedProximitySensorService();

  @override
  Future<bool> get isAvailable async => false;

  @override
  Stream<bool> get onNear => const Stream<bool>.empty();
}

ProximitySensorService createPlatformProximitySensorService() =>
    const UnsupportedProximitySensorService();
