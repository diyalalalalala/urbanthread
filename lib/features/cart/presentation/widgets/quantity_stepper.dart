import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// The minus / count / plus control on a cart line.
///
/// It reports the *absolute* quantity it wants, matching
/// `PATCH /cart/items/{itemId}`, which takes a value rather than a delta.
///
/// While a change is in flight the count keeps rendering the optimistic value
/// rather than a spinner: the number is the thing the customer is looking at,
/// and swapping it for a progress indicator would hide the very feedback the
/// optimistic update exists to provide. The buttons disable instead.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onChanged,
    super.key,
    this.minimum = 1,
    this.maximum = 10,
    this.isBusy = false,
    this.enabled = true,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  /// One, normally. The minus button at the minimum is still enabled and is
  /// wired to removal by the caller, which is what a customer expects from
  /// tapping minus on a single item.
  final int minimum;

  /// Capped at the server's per-line maximum of 10, or lower when the
  /// variant's stock says so.
  final int maximum;

  final bool isBusy;
  final bool enabled;

  bool get _canIncrease => enabled && !isBusy && quantity < maximum;
  bool get _canDecrease => enabled && !isBusy && quantity > minimum - 1;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: palette.line),
        borderRadius: AppDimens.borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            tooltip: quantity <= minimum ? 'Remove' : 'Decrease quantity',
            onPressed: _canDecrease ? () => onChanged(quantity - 1) : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: context.text.titleSmall?.copyWith(
                color: isBusy ? palette.inkMuted : palette.ink,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            tooltip: quantity >= maximum
                ? 'Maximum quantity reached'
                : 'Increase quantity',
            onPressed: _canIncrease ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          // Full tap target despite the compact visual size — a stepper is
          // tapped repeatedly and a cramped one causes mis-taps.
          width: AppDimens.minTapTarget,
          height: AppDimens.controlHeightSm,
          child: Icon(
            icon,
            size: 16,
            color: onPressed == null ? palette.inkSubtle : palette.ink,
          ),
        ),
      ),
    );
  }
}
