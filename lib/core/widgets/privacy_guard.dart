import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/context_extensions.dart';
import '../sensors/sensor_providers.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Covers whatever it wraps while the proximity sensor reports something close
/// to the screen — a face at the earpiece, a phone slipped into a pocket,
/// someone leaning over a shoulder.
///
/// Wrap the sensitive subtree, not the whole app: an order total, an address
/// book, a profile. Watching this widget is what subscribes to the sensor, so
/// a screen that is not guarded costs nothing at all, and closing the last
/// guarded screen releases the hardware.
///
/// **Why an opaque panel and not a blur.** A blur has to wrap the child, which
/// means the subtree changes shape every time the mask appears — losing scroll
/// offsets and half-typed fields — and it forces a full-screen `saveLayer` on
/// every frame it is up. The panel sits *over* an untouched child instead: the
/// tree is identical whether the mask is showing or not, nothing rebuilds
/// beneath it, and a solid fill hides strictly more than a blur does.
///
/// Interaction is blocked while masked (the panel is an opaque hit target, and
/// the child is additionally made non-interactive), semantics are excluded so a
/// screen reader does not read out what the screen is hiding, and the keyboard
/// is dismissed on the way in so nothing can be typed into a field behind the
/// mask.
class PrivacyGuard extends ConsumerWidget {
  const PrivacyGuard({
    required this.child,
    super.key,
    this.label = 'Hidden for your privacy',
    this.hint = 'Move your phone away to show it again',
    this.enabled = true,
  });

  final Widget child;

  /// Headline on the panel. Worth setting per screen — "Payment details
  /// hidden" tells the user more than a generic string.
  final String label;

  /// The line underneath, explaining how to get the content back.
  final String hint;

  /// Set false to opt a screen out without unwrapping it.
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMasked = enabled && ref.watch(privacyShieldProvider);

    ref.listen(privacyShieldProvider, (previous, next) {
      // Drop the keyboard as the mask goes up, so a password field behind it
      // cannot keep receiving keystrokes.
      if (next && !(previous ?? false)) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Both wrappers are always present and only their flags flip, which is
        // what keeps the child's element — and therefore its state — alive
        // across a mask.
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
        // One announcement for the whole panel, in sentence case. The visual
        // text below is excluded so a screen reader does not read the same
        // words twice, once of them in shouted capitals.
        label: '$label. $hint',
        child: GestureDetector(
          // Opaque, so every tap, scroll and long-press lands here rather than
          // on the content underneath.
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
