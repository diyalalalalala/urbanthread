import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urbanthread/core/sensors/proximity_sensor_service.dart';
import 'package:urbanthread/core/sensors/sensor_providers.dart';
import 'package:urbanthread/core/theme/app_theme.dart';
import 'package:urbanthread/core/widgets/privacy_guard.dart';

/// A proximity sensor under the test's control, counting subscriptions so the
/// battery requirement can be asserted rather than assumed.
class FakeProximitySensorService implements ProximitySensorService {
  FakeProximitySensorService({this.available = true}) {
    _controller = StreamController<bool>.broadcast(
      onListen: () => isListening = true,
      onCancel: () => isListening = false,
    );
  }

  late final StreamController<bool> _controller;

  final bool available;

  /// True while something is subscribed to [onNear] — which on a real device
  /// is exactly when the sensor is registered and drawing power.
  bool isListening = false;

  @override
  Future<bool> get isAvailable async => available;

  @override
  Stream<bool> get onNear => _controller.stream;

  void report({required bool near}) => _controller.add(near);

  void fail() => _controller.addError(StateError('no proximity sensor'));

  Future<void> dispose() => _controller.close();
}

void main() {
  late FakeProximitySensorService sensor;

  setUp(() => sensor = FakeProximitySensorService());
  tearDown(() => sensor.dispose());

  /// Pumps [child] behind a guard, inside enough of the real app to make the
  /// theme tokens the mask uses resolve.
  Future<void> pumpGuard(
    WidgetTester tester, {
    required Widget child,
    bool enabled = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proximitySensorServiceProvider.overrideWithValue(sensor),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: PrivacyGuard(
              label: 'Order details hidden',
              enabled: enabled,
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> moveNear(WidgetTester tester) async {
    sensor.report(near: true);
    await tester.pumpAndSettle();
  }

  Future<void> moveAway(WidgetTester tester) async {
    sensor.report(near: false);
    await tester.pumpAndSettle();
  }

  final mask = find.text('ORDER DETAILS HIDDEN');

  /// Every label in the *rendered* semantics tree. `find.bySemanticsLabel`
  /// reads widgets rather than the tree an assistive service actually walks,
  /// so it cannot see the effect of an `ExcludeSemantics`.
  List<String> semanticsLabels(WidgetTester tester) {
    final labels = <String>[];
    void visit(SemanticsNode node) {
      if (node.label.isNotEmpty) labels.add(node.label);
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    visit(tester.getSemantics(find.byType(MaterialApp)));
    return labels;
  }

  group('masking', () {
    testWidgets('shows the content while nothing is near', (tester) async {
      await pumpGuard(tester, child: const Text('NPR 4,290 · **** 1234'));

      expect(find.text('NPR 4,290 · **** 1234'), findsOneWidget);
      expect(mask, findsNothing);
    });

    testWidgets('covers the content when an object comes close',
        (tester) async {
      await pumpGuard(tester, child: const Text('NPR 4,290 · **** 1234'));

      await moveNear(tester);

      expect(mask, findsOneWidget);
      expect(
        find.text('Move your phone away to show it again'),
        findsOneWidget,
        reason: 'the mask has to say how to get the content back',
      );
    });

    testWidgets('restores the content when the device moves away',
        (tester) async {
      await pumpGuard(tester, child: const Text('NPR 4,290'));
      await moveNear(tester);

      await moveAway(tester);

      expect(mask, findsNothing);
      expect(find.text('NPR 4,290'), findsOneWidget);
    });

    testWidgets('blocks interaction with what it is hiding', (tester) async {
      var taps = 0;
      await pumpGuard(
        tester,
        child: Center(
          child: ElevatedButton(
            onPressed: () => taps++,
            child: const Text('PLACE ORDER'),
          ),
        ),
      );

      await moveNear(tester);
      // Tapping where the button is must hit the mask, not the button —
      // placing an order through a screen you cannot read would be worse than
      // showing it.
      await tester.tap(find.text('PLACE ORDER'), warnIfMissed: false);
      await tester.pump();

      expect(taps, 0);

      await moveAway(tester);
      await tester.tap(find.text('PLACE ORDER'));
      expect(taps, 1);
    });

    testWidgets('hides the content from screen readers too', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpGuard(tester, child: const Text('NPR 4,290'));

      expect(semanticsLabels(tester).join('\n'), contains('NPR 4,290'));

      await moveNear(tester);

      // The rendered semantics tree, not the widget tree: leaving the content
      // in it would have a screen reader announce precisely what the mask is
      // there to withhold.
      final announced = semanticsLabels(tester).join('\n');
      expect(announced, isNot(contains('NPR 4,290')));
      expect(announced, contains('Order details hidden'));

      semantics.dispose();
    });

    testWidgets('respects being disabled for a screen', (tester) async {
      await pumpGuard(tester, child: const Text('Public'), enabled: false);

      await moveNear(tester);

      expect(mask, findsNothing);
    });

    testWidgets('covers a whole scaffold, bottom bar included', (tester) async {
      // Checkout's arrangement: the delivery address is in the body but the
      // grand total and the submit button are in the bottom bar, so the guard
      // wraps the scaffold rather than its body.
      var placed = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [proximitySensorServiceProvider.overrideWithValue(sensor)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: PrivacyGuard(
              label: 'Checkout hidden',
              child: Scaffold(
                appBar: AppBar(title: const Text('Checkout')),
                body: const Center(child: Text('12 Jhamsikhel Road')),
                bottomNavigationBar: SizedBox(
                  height: 72,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () => placed++,
                      child: const Text('PLACE ORDER · NPR 4,290'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await moveNear(tester);
      await tester.tap(
        find.text('PLACE ORDER · NPR 4,290'),
        warnIfMissed: false,
      );
      await tester.pump();

      // The panel covers the app bar and the bottom bar as well as the body,
      // so nothing about the order — least of all placing it — is reachable.
      expect(find.text('CHECKOUT HIDDEN'), findsOneWidget);
      expect(placed, 0);

      await moveAway(tester);
      await tester.tap(find.text('PLACE ORDER · NPR 4,290'));
      expect(placed, 1);
    });
  });

  group('the guarded subtree survives a mask', () {
    testWidgets('keeps its scroll position', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await pumpGuard(
        tester,
        child: ListView(
          controller: controller,
          children: [
            for (var i = 0; i < 40; i++) SizedBox(height: 40, child: Text('$i')),
          ],
        ),
      );
      controller.jumpTo(320);
      await tester.pump();

      await moveNear(tester);
      await moveAway(tester);

      // The mask sits *over* an untouched child rather than wrapping it, so
      // nothing below it is rebuilt. Wrapping the child — in a blur, say —
      // would put the customer back at the top of their order history every
      // time the phone came near their face.
      expect(controller.offset, 320);
    });

    testWidgets('keeps what was typed into a form', (tester) async {
      await pumpGuard(
        tester,
        child: const Center(child: TextField(key: Key('note'))),
      );
      await tester.enterText(find.byKey(const Key('note')), 'Deliver to reception');

      await moveNear(tester);
      await moveAway(tester);

      expect(find.text('Deliver to reception'), findsOneWidget);
    });

    testWidgets('drops the keyboard on the way in', (tester) async {
      await pumpGuard(
        tester,
        child: const Center(child: TextField(key: Key('password'))),
      );
      await tester.tap(find.byKey(const Key('password')));
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.hasFocus, isTrue);

      await moveNear(tester);

      // Otherwise a password field behind the mask keeps receiving keystrokes
      // from a keyboard the customer can no longer see the target of.
      expect(
        FocusManager.instance.primaryFocus?.context?.widget,
        isNot(isA<EditableText>()),
      );
    });
  });

  group('devices without a proximity sensor', () {
    testWidgets('never mask, and never crash', (tester) async {
      sensor = FakeProximitySensorService(available: false);
      await pumpGuard(tester, child: const Text('NPR 4,290'));

      // The unsupported implementation emits nothing at all; this is the same
      // shape, plus the error a handset with no sensor raises on first listen.
      sensor.fail();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(mask, findsNothing);
      expect(find.text('NPR 4,290'), findsOneWidget);
    });

    testWidgets('a sensor that fails mid-session leaves content visible',
        (tester) async {
      await pumpGuard(tester, child: const Text('NPR 4,290'));
      await moveNear(tester);

      sensor.fail();
      await tester.pumpAndSettle();

      // Failing open matters more than failing safe here: a mask that cannot
      // be lifted because the sensor died is a screen the customer can never
      // read again.
      expect(mask, findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('battery', () {
    testWidgets('reads the sensor only while a guarded screen is up',
        (tester) async {
      await pumpGuard(tester, child: const Text('NPR 4,290'));

      expect(sensor.isListening, isTrue);

      // Navigating away from every guarded screen.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [proximitySensorServiceProvider.overrideWithValue(sensor)],
          child: const MaterialApp(home: Scaffold(body: Text('Catalogue'))),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        sensor.isListening,
        isFalse,
        reason: 'the auto-disposed provider must release the sensor',
      );
    });

    testWidgets('releases the sensor while the app is in the background',
        (tester) async {
      await pumpGuard(tester, child: const Text('NPR 4,290'));
      expect(sensor.isListening, isTrue);

      // The platform's own sequence — Flutter asserts on shortcuts.
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();

      expect(sensor.isListening, isFalse);

      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();

      expect(
        sensor.isListening,
        isTrue,
        reason: 'and picks it up again on return',
      );
    });
  });
}
