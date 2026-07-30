// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Device sensors, wired the same way as the rest of core: a keep-alive
/// provider per service, and an **auto-disposed** provider per *stream*.
///
/// The disposal difference is the whole battery story. A sensor costs nothing
/// while nobody is subscribed, and these stream providers are subscribed only
/// while a widget that needs them is on screen — so closing the last guarded
/// screen, or backgrounding the app, releases the hardware without anyone
/// having to remember to.

@ProviderFor(proximitySensorService)
final proximitySensorServiceProvider = ProximitySensorServiceProvider._();

/// Device sensors, wired the same way as the rest of core: a keep-alive
/// provider per service, and an **auto-disposed** provider per *stream*.
///
/// The disposal difference is the whole battery story. A sensor costs nothing
/// while nobody is subscribed, and these stream providers are subscribed only
/// while a widget that needs them is on screen — so closing the last guarded
/// screen, or backgrounding the app, releases the hardware without anyone
/// having to remember to.

final class ProximitySensorServiceProvider
    extends
        $FunctionalProvider<
          ProximitySensorService,
          ProximitySensorService,
          ProximitySensorService
        >
    with $Provider<ProximitySensorService> {
  /// Device sensors, wired the same way as the rest of core: a keep-alive
  /// provider per service, and an **auto-disposed** provider per *stream*.
  ///
  /// The disposal difference is the whole battery story. A sensor costs nothing
  /// while nobody is subscribed, and these stream providers are subscribed only
  /// while a widget that needs them is on screen — so closing the last guarded
  /// screen, or backgrounding the app, releases the hardware without anyone
  /// having to remember to.
  ProximitySensorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proximitySensorServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proximitySensorServiceHash();

  @$internal
  @override
  $ProviderElement<ProximitySensorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProximitySensorService create(Ref ref) {
    return proximitySensorService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProximitySensorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProximitySensorService>(value),
    );
  }
}

String _$proximitySensorServiceHash() =>
    r'b875053d4a711d5702304d9beae35e18a149a76d';

@ProviderFor(shakeDetector)
final shakeDetectorProvider = ShakeDetectorProvider._();

final class ShakeDetectorProvider
    extends $FunctionalProvider<ShakeDetector, ShakeDetector, ShakeDetector>
    with $Provider<ShakeDetector> {
  ShakeDetectorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shakeDetectorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shakeDetectorHash();

  @$internal
  @override
  $ProviderElement<ShakeDetector> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShakeDetector create(Ref ref) {
    return shakeDetector(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShakeDetector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShakeDetector>(value),
    );
  }
}

String _$shakeDetectorHash() => r'330ed6c02f1859a70b1b37746ba2fa413148ec50';

/// Whether this handset has a proximity sensor at all.
///
/// Nothing in the UI needs to gate on this — an absent sensor already produces
/// a stream that never emits — but the settings screen can use it to explain
/// why the feature is doing nothing.

@ProviderFor(hasProximitySensor)
final hasProximitySensorProvider = HasProximitySensorProvider._();

/// Whether this handset has a proximity sensor at all.
///
/// Nothing in the UI needs to gate on this — an absent sensor already produces
/// a stream that never emits — but the settings screen can use it to explain
/// why the feature is doing nothing.

final class HasProximitySensorProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether this handset has a proximity sensor at all.
  ///
  /// Nothing in the UI needs to gate on this — an absent sensor already produces
  /// a stream that never emits — but the settings screen can use it to explain
  /// why the feature is doing nothing.
  HasProximitySensorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasProximitySensorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasProximitySensorHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasProximitySensor(ref);
  }
}

String _$hasProximitySensorHash() =>
    r'52f67729a3e4a91e1fc8e48198eefb57a1eb3a26';

/// `true` while an object is close to the screen.
///
/// Re-created when the app leaves or re-enters the foreground: returning a
/// finished stream cancels the subscription underneath it, which is how the
/// sensor gets released while the app is in the background.

@ProviderFor(proximityNear)
final proximityNearProvider = ProximityNearProvider._();

/// `true` while an object is close to the screen.
///
/// Re-created when the app leaves or re-enters the foreground: returning a
/// finished stream cancels the subscription underneath it, which is how the
/// sensor gets released while the app is in the background.

final class ProximityNearProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// `true` while an object is close to the screen.
  ///
  /// Re-created when the app leaves or re-enters the foreground: returning a
  /// finished stream cancels the subscription underneath it, which is how the
  /// sensor gets released while the app is in the background.
  ProximityNearProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proximityNearProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proximityNearHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return proximityNear(ref);
  }
}

String _$proximityNearHash() => r'f4a3e2cceea9c029232ee0c7d0024440fe39d0b4';

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

@ProviderFor(privacyShield)
final privacyShieldProvider = PrivacyShieldProvider._();

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

final class PrivacyShieldProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
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
  PrivacyShieldProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privacyShieldProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privacyShieldHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return privacyShield(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$privacyShieldHash() => r'4a03434d1771ad21ba42457bcc5adbd516e4fd97';

/// One event per deliberate shake, while the app is in the foreground.

@ProviderFor(shakeEvents)
final shakeEventsProvider = ShakeEventsProvider._();

/// One event per deliberate shake, while the app is in the foreground.

final class ShakeEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ShakeEvent>,
          ShakeEvent,
          Stream<ShakeEvent>
        >
    with $FutureModifier<ShakeEvent>, $StreamProvider<ShakeEvent> {
  /// One event per deliberate shake, while the app is in the foreground.
  ShakeEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shakeEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shakeEventsHash();

  @$internal
  @override
  $StreamProviderElement<ShakeEvent> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<ShakeEvent> create(Ref ref) {
    return shakeEvents(ref);
  }
}

String _$shakeEventsHash() => r'3214a0adffea600237bda91d4b12023e8a5f0ee2';
