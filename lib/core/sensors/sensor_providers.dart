import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/app_lifecycle_providers.dart';
import 'proximity_sensor_service.dart';
import 'shake_detector.dart';

part 'sensor_providers.g.dart';

/// Device sensors, wired the same way as the rest of core: a keep-alive
/// provider per service, and an **auto-disposed** provider per *stream*.
///
/// The disposal difference is the whole battery story. A sensor costs nothing
/// while nobody is subscribed, and these stream providers are subscribed only
/// while a widget that needs them is on screen — so closing the last guarded
/// screen, or backgrounding the app, releases the hardware without anyone
/// having to remember to.

@Riverpod(keepAlive: true)
ProximitySensorService proximitySensorService(Ref ref) =>
    createProximitySensorService();

@Riverpod(keepAlive: true)
ShakeDetector shakeDetector(Ref ref) => ShakeDetectorImpl();

/// Whether this handset has a proximity sensor at all.
///
/// Nothing in the UI needs to gate on this — an absent sensor already produces
/// a stream that never emits — but the settings screen can use it to explain
/// why the feature is doing nothing.
@riverpod
Future<bool> hasProximitySensor(Ref ref) =>
    ref.watch(proximitySensorServiceProvider).isAvailable;

/// `true` while an object is close to the screen.
///
/// Re-created when the app leaves or re-enters the foreground: returning a
/// finished stream cancels the subscription underneath it, which is how the
/// sensor gets released while the app is in the background.
@riverpod
Stream<bool> proximityNear(Ref ref) {
  if (!ref.watch(isAppForegroundProvider)) return Stream.value(false);
  return ref.watch(proximitySensorServiceProvider).onNear;
}

/// Whether sensitive content should be obscured right now.
///
/// Collapses the stream to a plain bool the same way `isOnlineProvider` does,
/// so a widget reads a boolean instead of unpacking an [AsyncValue].
///
/// This deliberately **fails open**. Loading means the first reading has not
/// arrived, and an error means the sensor stopped answering — and an error is
/// checked before the value because a stream that dies while an object is near
/// keeps reporting its last reading, which would leave a mask that can never
/// be lifted over a screen the customer needs.
@riverpod
bool privacyShield(Ref ref) {
  final near = ref.watch(proximityNearProvider);
  if (near.hasError) return false;
  return near.value ?? false;
}

/// One event per deliberate shake, while the app is in the foreground.
@riverpod
Stream<ShakeEvent> shakeEvents(Ref ref) {
  if (!ref.watch(isAppForegroundProvider)) return const Stream.empty();
  return ref.watch(shakeDetectorProvider).onShake;
}
