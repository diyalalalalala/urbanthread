import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:urbanthread/core/sensors/shake_detector.dart';

/// The whole value of this class is in what it *rejects*. A threshold low
/// enough to catch a gentle shake also catches a phone being set down on a
/// table, and a refresh that fires when the customer puts their phone in a
/// pocket is worse than no feature at all — so each rejection case is pinned
/// as tightly as the acceptance one.
///
/// Timing comes from the sample timestamps, which is what makes replaying a
/// two-second gesture instantaneous here.
void main() {
  const gravity = 9.80665;
  final origin = DateTime.utc(2026, 7, 30);

  /// A sample of [g] total force, [at] milliseconds into the gesture.
  AccelerometerEvent sample(double g, int at) => AccelerometerEvent(
        0,
        0,
        g * gravity,
        origin.add(Duration(milliseconds: at)),
      );

  /// Samples at rest read 1g — gravity is included in the reading.
  AccelerometerEvent atRest(int at) => sample(1, at);

  ShakeDetectorImpl detectorOver(List<AccelerometerEvent> samples) =>
      ShakeDetectorImpl(
        source: ({Duration samplingPeriod = SensorInterval.gameInterval}) =>
            Stream.fromIterable(samples),
      );

  Future<List<ShakeEvent>> shakesFrom(List<AccelerometerEvent> samples) =>
      detectorOver(samples).onShake.toList();

  group('accepts', () {
    test('two jolts inside the window are a shake', () async {
      final shakes = await shakesFrom([
        atRest(0),
        sample(3.1, 100),
        atRest(200),
        sample(3.4, 300),
      ]);

      expect(shakes, hasLength(1));
      expect(shakes.single.gForce, closeTo(3.4, 0.01));
      expect(shakes.single.at, origin.add(const Duration(milliseconds: 300)));
    });

    test('a shake after the cooldown fires again', () async {
      final shakes = await shakesFrom([
        sample(3, 0),
        sample(3, 200),
        // Well past the two-second cooldown.
        sample(3, 2400),
        sample(3, 2600),
      ]);

      expect(shakes, hasLength(2));
    });
  });

  group('rejects', () {
    test('a phone at rest', () async {
      expect(await shakesFrom([for (var i = 0; i < 50; i++) atRest(i * 20)]),
          isEmpty);
    });

    test('ordinary handling — a pocket, a walk, a phone picked up', () async {
      // Peaks around 1.5g: real movement, nowhere near a deliberate shake.
      final shakes = await shakesFrom([
        for (var i = 0; i < 40; i++) sample(1 + (i % 4) * 0.18, i * 25),
      ]);

      expect(shakes, isEmpty);
    });

    test('a single knock, however hard', () async {
      // A phone dropped onto a desk is one big spike, not a shake. This is the
      // case `requiredJolts` exists for.
      final shakes = await shakesFrom([atRest(0), sample(6, 100), atRest(200)]);

      expect(shakes, isEmpty);
    });

    test('the burst of samples within one swing', () async {
      // At 50Hz a single swing of the wrist stays above the threshold for
      // several consecutive samples. Without `minJoltGap` those alone would
      // add up to a shake.
      final shakes = await shakesFrom([
        for (var i = 0; i < 5; i++) sample(3.2, i * 20),
      ]);

      expect(shakes, isEmpty);
    });

    test('two jolts too far apart to be one gesture', () async {
      final shakes = await shakesFrom([
        sample(3, 0),
        // Past the 800ms window: someone shook it once, put it down, and
        // knocked it a second later.
        sample(3, 1200),
      ]);

      expect(shakes, isEmpty);
    });
  });

  group('one gesture, one refresh', () {
    test('a two-second continuous shake emits exactly once', () async {
      // The requirement the debounce exists for: whatever the user does with
      // their wrist, one shake means one refresh.
      final shakes = await shakesFrom([
        for (var i = 0; i < 14; i++) sample(3.5, i * 150),
      ]);

      expect(shakes, hasLength(1));
    });
  });

  group('unsupported devices', () {
    test('a sensor that errors closes the stream instead of throwing',
        () async {
      // Android reports a missing accelerometer by erroring on first listen.
      final detector = ShakeDetectorImpl(
        source: ({Duration samplingPeriod = SensorInterval.gameInterval}) =>
            Stream<AccelerometerEvent>.error(StateError('no accelerometer')),
      );

      // Completing empty is what lets the feature disappear quietly; throwing
      // here would take down whichever screen happened to be listening.
      expect(await detector.onShake.toList(), isEmpty);
    });
  });

  group('subscription', () {
    test('the accelerometer is only read while something is listening',
        () async {
      var listening = false;
      final controller = StreamController<AccelerometerEvent>(
        onListen: () => listening = true,
        onCancel: () => listening = false,
      );
      addTearDown(controller.close);

      final detector = ShakeDetectorImpl(
        source: ({Duration samplingPeriod = SensorInterval.gameInterval}) =>
            controller.stream,
      );

      expect(listening, isFalse, reason: 'nothing listening yet');

      final subscription = detector.onShake.listen((_) {});
      await pumpEventQueue();
      expect(listening, isTrue);

      await subscription.cancel();
      expect(listening, isFalse, reason: 'sensor released with the listener');
    });

    test('each subscription tracks its own jolts', () async {
      // Two screens listening at once must not consume each other's jolts —
      // one would then see a shake the user never made.
      final detector = detectorOver([sample(3, 0), sample(3, 200)]);

      expect(await detector.onShake.toList(), hasLength(1));
      expect(await detector.onShake.toList(), hasLength(1));
    });
  });
}
