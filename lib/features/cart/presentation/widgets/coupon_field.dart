import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/cart_summary.dart';

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

  final Future<void> Function(String code) onApply;

  final VoidCallback onRemove;
  final bool isBusy;

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
                style: AppTheme.hugContent,
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
