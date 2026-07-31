import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/app_lifecycle_providers.dart';
import 'proximity_sensor_service.dart';
import 'shake_detector.dart';

part 'sensor_providers.g.dart';

@Riverpod(keepAlive: true)
ProximitySensorService proximitySensorService(Ref ref) =>
    createProximitySensorService();

@Riverpod(keepAlive: true)
ShakeDetector shakeDetector(Ref ref) => ShakeDetectorImpl();

@riverpod
Future<bool> hasProximitySensor(Ref ref) =>
    ref.watch(proximitySensorServiceProvider).isAvailable;

@riverpod
Stream<bool> proximityNear(Ref ref) {
  if (!ref.watch(isAppForegroundProvider)) return Stream.value(false);
  return ref.watch(proximitySensorServiceProvider).onNear;
}

@riverpod
bool privacyShield(Ref ref) {
  final near = ref.watch(proximityNearProvider);
  if (near.hasError) return false;
  return near.value ?? false;
}

@riverpod
Stream<ShakeEvent> shakeEvents(Ref ref) {
  if (!ref.watch(isAppForegroundProvider)) return const Stream.empty();
  return ref.watch(shakeDetectorProvider).onShake;
}
