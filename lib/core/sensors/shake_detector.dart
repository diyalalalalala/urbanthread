import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeEvent {
  ShakeEvent({required this.at, required this.gForce});

  final DateTime at;

  final double gForce;

  @override
  String toString() => 'ShakeEvent(${gForce.toStringAsFixed(2)}g at $at)';
}

abstract interface class ShakeDetector {
  Stream<ShakeEvent> get onShake;
}

typedef AccelerometerSource = Stream<AccelerometerEvent> Function({
  Duration samplingPeriod,
});

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

  static const _earthGravity = 9.80665;

  final AccelerometerSource _source;

  final double threshold;

  final int requiredJolts;

  final Duration joltWindow;

  final Duration minJoltGap;

  final Duration cooldown;

  final Duration samplingPeriod;

  @override
  Stream<ShakeEvent> get onShake {
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
