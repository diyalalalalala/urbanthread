// The mobile implementation imports `proximity_sensor`, which imports
// `dart:io` — a library that does not exist on the web and fails to *compile*
// there, not merely at runtime. So the platform split is a conditional import
// rather than a runtime `if`: web and any other io-less target get the
// unsupported implementation and never see the plugin at all.
import 'proximity_sensor_service_unsupported.dart'
    if (dart.library.io) 'proximity_sensor_service_mobile.dart';

/// Reports whether something — a face, usually — is close to the screen.
///
/// An interface rather than a direct call into the plugin, for the same reason
/// [NetworkInfo] is one: the widgets that consume it must be testable without
/// a device, and the graceful-degradation rules (no sensor, no platform
/// support, a sensor that errors on first listen) belong in one place instead
/// of at every call site.
abstract interface class ProximitySensorService {
  /// Whether this device can answer the question at all.
  ///
  /// False on a handset with no proximity sensor, on desktop and on the web.
  /// Never throws — an unavailable sensor is a fact, not an error.
  Future<bool> get isAvailable;

  /// Emits `true` while an object is near the screen and `false` when it moves
  /// away, de-duplicated so a stationary phone produces no events.
  ///
  /// The native listener is registered on first subscription and released on
  /// cancel, which is what keeps the sensor off when nothing is watching. A
  /// device without the sensor yields a stream that simply never emits.
  Stream<bool> get onNear;
}

/// The implementation for the platform this build targets.
ProximitySensorService createProximitySensorService() =>
    createPlatformProximitySensorService();
