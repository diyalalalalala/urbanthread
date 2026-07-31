import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/context_extensions.dart';
import '../sensors/sensor_providers.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

class PrivacyGuard extends ConsumerWidget {
  const PrivacyGuard({
    required this.child,
    super.key,
    this.label = 'Hidden for your privacy',
    this.hint = 'Move your phone away to show it again',
    this.enabled = true,
  });

  final Widget child;

  final String label;

  final String hint;

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMasked = enabled && ref.watch(privacyShieldProvider);

    ref.listen(privacyShieldProvider, (previous, next) {
      if (next && !(previous ?? false)) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    return Stack(
      fit: StackFit.passthrough,
      children: [
        ExcludeSemantics(
          excluding: isMasked,
          child: IgnorePointer(ignoring: isMasked, child: child),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: AppDimens.durationFast,
            child: isMasked
                ? _PrivacyMask(label: label, hint: hint)
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _PrivacyMask extends StatelessWidget {
  const _PrivacyMask({required this.label, required this.hint});

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$label. $hint',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: ColoredBox(
            color: context.palette.canvas,
            child: ExcludeSemantics(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.space32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_off_outlined,
                        size: 44,
                        color: context.palette.inkSubtle,
                      ),
                      const SizedBox(height: AppDimens.space20),
                      Text(
                        label.toUpperCase(),
                        style: AppTypography.eyebrow.copyWith(
                          color: context.palette.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimens.space12),
                      Text(
                        hint,
                        style: context.text.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
