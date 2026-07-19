import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/cart_summary.dart';

/// Enter, apply and remove a coupon code.
///
/// Three states, and the third is the one that is easy to miss: a code can be
/// *attached* to the cart and still be worth nothing, because the summary
/// re-validates it on every read and a code can expire or hit its usage limit
/// while the cart sits idle. So an applied-but-rejected coupon gets its own
/// treatment with the server's reason, rather than being drawn as a success.
class CouponField extends StatefulWidget {
  const CouponField({
    required this.summary,
    required this.onApply,
    required this.onRemove,
    super.key,
    this.isBusy = false,
    this.errorText,
    this.enabled = true,
  });

  final CartSummary summary;

  /// Returns once the request settles, so the field can clear itself only on
  /// a code the server actually took.
  final Future<void> Function(String code) onApply;

  final VoidCallback onRemove;
  final bool isBusy;

  /// A rejection from the server, shown under the field. A bad code is a form
  /// error, not a transient toast.
  final String? errorText;

  final bool enabled;

  @override
  State<CouponField> createState() => _CouponFieldState();
}

class _CouponFieldState extends State<CouponField> {
  final _controller = TextEditingController();

  @override
  void didUpdateWidget(CouponField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A newly-applied code moves into the chip above, so the input has served
    // its purpose and should not keep showing what is now displayed twice.
    final applied = widget.summary.coupon?.valid ?? false;
    final wasApplied = oldWidget.summary.coupon?.valid ?? false;
    if (applied && !wasApplied) _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    // The route's validator wants 3–24 characters; checking here saves a round
    // trip and gives a faster, more specific message than the 422 would.
    if (code.length < 3) return;
    await widget.onApply(code);
  }

  @override
  Widget build(BuildContext context) {
    final coupon = widget.summary.coupon;

    if (coupon != null && coupon.valid) {
      return _AppliedCoupon(
        coupon: coupon,
        onRemove: widget.isBusy ? null : widget.onRemove,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (coupon != null && !coupon.valid) ...[
          _RejectedCoupon(
            coupon: coupon,
            onRemove: widget.isBusy ? null : widget.onRemove,
          ),
          const SizedBox(height: AppDimens.space12),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled && !widget.isBusy,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                maxLength: 24,
                // Uppercased server-side anyway; doing it here means the field
                // shows what will actually be applied.
                inputFormatters: [UpperCaseTextFormatter()],
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Coupon code',
                  counterText: '',
                  errorText: widget.errorText,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            SizedBox(
              height: AppDimens.controlHeight,
              child: OutlinedButton(
                onPressed:
                    widget.enabled && !widget.isBusy ? _submit : null,
                child: widget.isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('APPLY'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Uppercases as the customer types, matching what the backend stores.
class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
}

class _AppliedCoupon extends StatelessWidget {
  const _AppliedCoupon({required this.coupon, required this.onRemove});

  final CartSummaryCoupon coupon;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space12,
      ),
      decoration: BoxDecoration(
        color: palette.successSubtle,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined, size: 16, color: palette.success),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.code,
                  style: AppTypography.eyebrow.copyWith(color: palette.success),
                ),
                const SizedBox(height: AppDimens.space2),
                Text(
                  'You saved ${Formatters.price(coupon.discountAmount)}',
                  style: context.text.bodySmall
                      ?.copyWith(color: palette.success),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRemove,
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }
}

class _RejectedCoupon extends StatelessWidget {
  const _RejectedCoupon({required this.coupon, required this.onRemove});

  final CartSummaryCoupon coupon;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space16,
        vertical: AppDimens.space12,
      ),
      decoration: BoxDecoration(
        color: palette.warningSubtle,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: palette.warning),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Text(
              // The backend's own reason — "this coupon has expired", "minimum
              // spend not met". Far more useful than a generic refusal.
              coupon.message ?? '${coupon.code} no longer applies.',
              style: context.text.bodySmall?.copyWith(color: palette.warning),
            ),
          ),
          TextButton(onPressed: onRemove, child: const Text('REMOVE')),
        ],
      ),
    );
  }
}
