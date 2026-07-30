import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/context_extensions.dart';
import '../sensors/sensor_providers.dart';
import '../sensors/shake_detector.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// What a shake should do, and what to say once it is done.
///
/// Returns the confirmation to show, or null to stay silent — which is the
/// right answer when the refresh failed, because every screen that uses this
/// already renders its own failure inline and a toast would just say the
/// opposite of what the screen shows.
typedef ShakeRefreshHandler = Future<String?> Function();

/// Reloads the screen it wraps when the user shakes the device.
///
/// It owns detection, the progress indicator and the re-entrancy guard;
/// [onRefresh] owns what "refresh" means. So this adds a gesture to the
/// screen's existing refresh path rather than a second way of loading the same
/// data — the handler is normally the same notifier call pull-to-refresh
/// already uses.
///
/// **Listening is scoped to the screen being genuinely on display**, which is
/// stricter than "mounted". The shell keeps every tab alive in an
/// `IndexedStack`, so a mounted cart page may be four tabs away, and a pushed
/// product page may be covering it. Both cases are detected — `TickerMode` for
/// the inactive branch, `ModalRoute.isCurrent` for the covered route — and
/// while either says no, the listener is not registered at all, so the
/// accelerometer stays off.
class ShakeToRefresh extends ConsumerStatefulWidget {
  const ShakeToRefresh({
    required this.onRefresh,
    required this.child,
    super.key,
    this.enabled = true,
  });

  final ShakeRefreshHandler onRefresh;
  final Widget child;

  /// Set false to opt out without unwrapping — useful while a screen is in a
  /// state where reloading would be meaningless.
  final bool enabled;

  @override
  ConsumerState<ShakeToRefresh> createState() => _ShakeToRefreshState();
}

class _ShakeToRefreshState extends ConsumerState<ShakeToRefresh> {
  bool _isRefreshing = false;

  /// True only when this screen is the one the user is looking at.
  bool get _isOnScreen {
    // `TickerMode` is go_router's own signal: `StatefulShellRoute` disables it
    // on the branches that are not showing.
    if (!TickerMode.valuesOf(context).enabled) return false;
    // Null for a screen that is not inside a route (a test harness, a sheet
    // body) — treat that as visible rather than refusing to work there.
    return ModalRoute.of(context)?.isCurrent ?? true;
  }

  Future<void> _refresh() async {
    // The second half of the debounce: the detector's cooldown stops a single
    // gesture emitting twice, and this stops a shake landing while the request
    // it already triggered is still in flight.
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    try {
      final message = await widget.onRefresh();
      if (!mounted) return;
      if (message != null) context.showSnack(message);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Registering the listener *is* the subscription. Not registering it on a
    // build where the screen is hidden is what stops the sensor: Riverpod
    // drops listeners that a rebuild did not renew, and `shakeEventsProvider`
    // is auto-disposed.
    if (widget.enabled && _isOnScreen) {
      ref.listen(shakeEventsProvider, (previous, next) {
        // Errors and the initial loading state are not shakes. A handset
        // without an accelerometer only ever produces those.
        if (next is AsyncData<ShakeEvent>) unawaited(_refresh());
      });
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: AppDimens.durationFast,
            child: _isRefreshing
                ? const _ShakeRefreshBanner()
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// The progress strip shown while a shake-triggered refresh runs.
///
/// Deliberately shaped like `OfflineBanner`: same height, same eyebrow type,
/// same "informs without interrupting" role. The content stays readable
/// underneath, because the data on screen is still valid until the new data
/// lands.
class _ShakeRefreshBanner extends StatelessWidget {
  const _ShakeRefreshBanner();

  @override
  Widget build(BuildContext context) => Material(
        color: context.palette.accentSubtle,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.pageGutter,
            vertical: AppDimens.space8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.palette.accent,
                ),
              ),
              const SizedBox(width: AppDimens.space8),
              Text(
                'REFRESHING',
                style: AppTypography.eyebrow.copyWith(
                  color: context.palette.accent,
                ),
              ),
            ],
          ),
        ),
      );
}
