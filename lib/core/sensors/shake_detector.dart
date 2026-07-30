import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A shake the user meant.
///
/// Deliberately not a value type and deliberately not const: two shakes must
/// compare unequal, or a listener watching an `AsyncValue<ShakeEvent>` would
/// not fire for the second one.
class ShakeEvent {
  ShakeEvent({required this.at, required this.gForce});

  /// When the shake completed, on the sensor's own clock.
  final DateTime at;

  /// Peak force of the jolt that completed it, in g. Useful in logs when
  /// tuning the threshold on a real handset.
  final double gForce;

  @override
  String toString() => 'ShakeEvent(${gForce.toStringAsFixed(2)}g at $at)';
}

/// Turns raw accelerometer samples into deliberate shakes.
abstract interface class ShakeDetector {
  /// One event per shake. The subscription is what turns the accelerometer on,
  /// so cancelling it is what turns it off again.
  ///
  /// A device with no accelerometer yields a stream that closes without
  /// emitting rather than one that throws.
  Stream<ShakeEvent> get onShake;
}

/// Signature of `accelerometerEventStream` from `sensors_plus`, so a test can
/// feed synthetic samples in without a device.
typedef AccelerometerSource = Stream<AccelerometerEvent> Function({
  Duration samplingPeriod,
});

/// Shake detection over `sensors_plus`.
///
/// The rule: a *shake* is at least [requiredJolts] separate jolts above
/// [threshold] within [joltWindow]. One jolt is a knock or a phone dropped
/// onto a desk, and refreshing on those would make the feature feel haunted.
/// Requiring two reversals is what distinguishes "shaken" from "bumped".
///
/// [cooldown] then bounds how often a shake can fire at all. It is the reason
/// one continuous shake produces one refresh: the burst of samples that make
/// up the gesture is spent inside the window and the cooldown covers the tail.
///
/// Timing comes from the sample timestamps rather than the wall clock, which
/// keeps the whole detector a pure function of its input stream — a test can
/// replay a shake in microseconds.
class ShakeDetectorImpl implements ShakeDetector {
  ShakeDetectorImpl({
    AccelerometerSource? source,
    this.threshold = 2.3,
    this.requiredJolts = 2,
    this.joltWindow = const Duration(milliseconds: 800),
    this.minJoltGap = const Duration(milliseconds: 100),
    this.cooldown = const Duration(seconds: 2),
    this.samplingPeriod = SensorInterval.gameInterval,
  }) : _source = source ?? accelerometerEventStream;

  /// Standard gravity, so [threshold] can be read in g.
  static const _earthGravity = 9.80665;

  final AccelerometerSource _source;

  /// Total acceleration, in g, that counts as a jolt. A phone at rest reads
  /// 1.0g; a purposeful shake peaks well above 2g, while pocket movement and
  /// walking stay below it.
  final double threshold;

  /// Jolts needed within [joltWindow] to call it a shake.
  final int requiredJolts;

  final Duration joltWindow;

  /// Minimum spacing between two jolts. A single swing of the wrist produces a
  /// run of high-g samples; without this they would count as a whole shake on
  /// their own.
  final Duration minJoltGap;

  /// Quiet period after a shake fires. Also the debounce that stops one
  /// gesture triggering several refreshes.
  final Duration cooldown;

  /// 50Hz. Fast enough to catch the reversals in a shake, slow enough that the
  /// stream is not a meaningful battery cost while a screen is open.
  final Duration samplingPeriod;

  @override
  Stream<ShakeEvent> get onShake {
    // Per-subscription state, so listening twice cannot have one subscriber
    // consuming the other's jolts.
    final jolts = <DateTime>[];
    DateTime? firedAt;

    return _source(samplingPeriod: samplingPeriod).transform(
      StreamTransformer<AccelerometerEvent, ShakeEvent>.fromHandlers(
        handleData: (sample, sink) {
          final at = sample.timestamp;
          final gForce = math.sqrt(
                sample.x * sample.x +
                    sample.y * sample.y +
                    sample.z * sample.z,
              ) /
              _earthGravity;

          if (gForce < threshold) return;
          if (jolts.isNotEmpty && at.difference(jolts.last) < minJoltGap) {
            return;
          }

          jolts
            ..add(at)
            ..removeWhere((jolt) => at.difference(jolt) > joltWindow);

          if (jolts.length < requiredJolts) return;
          if (firedAt != null && at.difference(firedAt!) < cooldown) return;

          firedAt = at;
          jolts.clear();
          sink.add(ShakeEvent(at: at, gForce: gForce));
        },
        handleError: (error, stackTrace, sink) {
          // Android reports a missing accelerometer by erroring the stream.
          // Close quietly: the feature disappears on that handset, and every
          // other gesture on the screen keeps working.
          assert(() {
            debugPrint('Accelerometer unavailable, shake-to-refresh off: '
                '$error');
            return true;
          }());
          sink.close();
        },
      ),
    );
  }
}
