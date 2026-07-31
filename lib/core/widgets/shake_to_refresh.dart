import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/context_extensions.dart';
import '../sensors/sensor_providers.dart';
import '../sensors/shake_detector.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

typedef ShakeRefreshHandler = Future<String?> Function();

class ShakeToRefresh extends ConsumerStatefulWidget {
  const ShakeToRefresh({
    required this.onRefresh,
    required this.child,
    super.key,
    this.enabled = true,
  });

  final ShakeRefreshHandler onRefresh;
  final Widget child;

  final bool enabled;

  @override
  ConsumerState<ShakeToRefresh> createState() => _ShakeToRefreshState();
}

class _ShakeToRefreshState extends ConsumerState<ShakeToRefresh> {
  bool _isRefreshing = false;

  bool get _isOnScreen {
    if (!TickerMode.valuesOf(context).enabled) return false;
    return ModalRoute.of(context)?.isCurrent ?? true;
  }

  Future<void> _refresh() async {
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
    if (widget.enabled && _isOnScreen) {
      ref.listen(shakeEventsProvider, (previous, next) {
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
