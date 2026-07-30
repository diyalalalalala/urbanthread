import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/core/sensors/sensor_providers.dart';
import 'package:urbanthread/core/sensors/shake_detector.dart';
import 'package:urbanthread/core/theme/app_theme.dart';
import 'package:urbanthread/core/widgets/shake_to_refresh.dart';

/// A shake detector the test drives, counting subscriptions so "stops
/// listening when the screen is inactive" can be asserted directly rather than
/// inferred from the absence of a refresh.
class FakeShakeDetector implements ShakeDetector {
  FakeShakeDetector() {
    _controller = StreamController<ShakeEvent>.broadcast(
      onListen: () => isListening = true,
      onCancel: () => isListening = false,
    );
  }

  late final StreamController<ShakeEvent> _controller;

  /// True while something is subscribed — on a device, while the accelerometer
  /// is actually being read.
  bool isListening = false;

  @override
  Stream<ShakeEvent> get onShake => _controller.stream;

  void shake() => _controller.add(
        ShakeEvent(at: DateTime.utc(2026, 7, 30), gForce: 3.4),
      );

  /// What a handset with no accelerometer does on first listen.
  void fail() => _controller.addError(StateError('no accelerometer'));

  Future<void> dispose() => _controller.close();
}

void main() {
  late FakeShakeDetector detector;
  late int refreshes;

  setUp(() {
    detector = FakeShakeDetector();
    refreshes = 0;
  });

  tearDown(() => detector.dispose());

  /// Pumps a screen wrapped in [ShakeToRefresh] inside a route, so
  /// `ModalRoute.isCurrent` behaves as it does in the app.
  ///
  /// [onScreen] false wraps the subject in a disabled `TickerMode`, which is
  /// exactly what `StatefulShellRoute` does to the tabs that are not showing.
  Future<void> pumpScreen(
    WidgetTester tester, {
    Future<String?> Function()? onRefresh,
    bool onScreen = true,
    bool enabled = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [shakeDetectorProvider.overrideWithValue(detector)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: TickerMode(
            enabled: onScreen,
            child: Scaffold(
              body: ShakeToRefresh(
                enabled: enabled,
                onRefresh: onRefresh ??
                    () async {
                      refreshes++;
                      return 'Product list updated';
                    },
                child: const Center(child: Text('Catalogue')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  final banner = find.text('REFRESHING');

  group('refreshing', () {
    testWidgets('a shake reloads the screen and confirms it', (tester) async {
      await pumpScreen(tester);

      detector.shake();
      await tester.pumpAndSettle();

      expect(refreshes, 1);
      expect(
        find.text('Product list updated'),
        findsOneWidget,
        reason: 'a refresh with no visible outcome needs saying out loud',
      );
    });

    testWidgets('shows a progress banner while the request is in flight',
        (tester) async {
      final inFlight = Completer<String?>();
      await pumpScreen(tester, onRefresh: () => inFlight.future);

      expect(banner, findsNothing);

      detector.shake();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(banner, findsOneWidget);
      // The stale data stays readable underneath — it is still the truth until
      // the new data lands.
      expect(find.text('Catalogue'), findsOneWidget);

      inFlight.complete('Product list updated');
      await tester.pumpAndSettle();

      expect(banner, findsNothing);
    });

    testWidgets('stays silent when the handler has nothing to confirm',
        (tester) async {
      // What a screen returns when the refresh failed: the failure is already
      // rendered inline, and "updated" would contradict it.
      await pumpScreen(tester, onRefresh: () async => null);

      detector.shake();
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('one shake, one request', () {
    testWidgets('a shake during a refresh is dropped', (tester) async {
      final inFlight = Completer<String?>();
      await pumpScreen(
        tester,
        onRefresh: () {
          refreshes++;
          return inFlight.future;
        },
      );

      detector.shake();
      await tester.pump();
      // Whatever the sensor makes of the tail of the gesture, the request
      // already running is the only one.
      detector.shake();
      detector.shake();
      await tester.pump();

      expect(refreshes, 1);

      inFlight.complete(null);
      await tester.pumpAndSettle();

      // And the screen is armed again once it finishes.
      detector.shake();
      await tester.pumpAndSettle();
      expect(refreshes, 2);
    });
  });

  group('scoping', () {
    testWidgets('ignores shakes while the screen is not the one showing',
        (tester) async {
      await pumpScreen(tester, onScreen: false);

      detector.shake();
      await tester.pumpAndSettle();

      // The cart tab stays mounted in the shell's IndexedStack while the
      // customer browses the catalogue. Refreshing it from here would fire
      // three requests for one shake.
      expect(refreshes, 0);
      expect(
        detector.isListening,
        isFalse,
        reason: 'an off-screen tab must not hold the accelerometer open',
      );
    });

    testWidgets('picks the sensor up when the screen becomes active',
        (tester) async {
      await pumpScreen(tester, onScreen: false);
      expect(detector.isListening, isFalse);

      await pumpScreen(tester, onScreen: true);

      expect(detector.isListening, isTrue);

      detector.shake();
      await tester.pumpAndSettle();
      expect(refreshes, 1);
    });

    testWidgets('respects being disabled', (tester) async {
      await pumpScreen(tester, enabled: false);

      detector.shake();
      await tester.pumpAndSettle();

      expect(refreshes, 0);
      expect(detector.isListening, isFalse);
    });

    testWidgets('releases the accelerometer when the screen is disposed',
        (tester) async {
      await pumpScreen(tester);
      expect(detector.isListening, isTrue);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [shakeDetectorProvider.overrideWithValue(detector)],
          child: const MaterialApp(home: Scaffold(body: Text('Settings'))),
        ),
      );
      await tester.pumpAndSettle();

      expect(detector.isListening, isFalse);
    });

    testWidgets('releases the accelerometer while the app is backgrounded',
        (tester) async {
      await pumpScreen(tester);
      expect(detector.isListening, isTrue);

      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();

      expect(detector.isListening, isFalse);

      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();

      expect(detector.isListening, isTrue);
    });
  });

  group('unsupported devices', () {
    testWidgets('a sensor error never refreshes and never crashes',
        (tester) async {
      await pumpScreen(tester);

      detector.fail();
      await tester.pumpAndSettle();

      expect(refreshes, 0);
      expect(tester.takeException(), isNull);
      expect(find.text('Catalogue'), findsOneWidget);
    });
  });
}
