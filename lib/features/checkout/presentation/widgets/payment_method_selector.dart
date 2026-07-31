import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../orders/domain/entities/order.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    required this.selected,
    required this.onSelected,
    super.key,
    this.declineWarning = false,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelected;

  final bool declineWarning;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        for (final method in PaymentMethod.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.space8),
            child: _MethodTile(
              method: method,
              isSelected: selected == method,
              onTap: () => onSelected(method),
            ),
          ),
        if (declineWarning && selected == PaymentMethod.mockGateway)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppDimens.space4),
            padding: const EdgeInsets.all(AppDimens.space12),
            decoration: BoxDecoration(
              color: palette.warningSubtle,
              borderRadius: AppDimens.borderRadius,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  size: 18,
                  color: palette.warning,
                ),
                const SizedBox(width: AppDimens.space8),
                Expanded(
                  child: Text(
                    'The demo gateway declines totals ending in 7, so this '
                    'payment will be refused and no order will be created. '
                    'Choose cash on delivery, or adjust your basket.',
                    style: context.text.bodySmall?.copyWith(
                      color: palette.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(
            color: isSelected ? palette.accent : palette.line,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: AppDimens.borderRadius,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected ? palette.accent : palette.lineStrong,
            ),
            const SizedBox(width: AppDimens.space12),
            Icon(
              method == PaymentMethod.cod
                  ? Icons.payments_outlined
                  : Icons.credit_card_outlined,
              size: 20,
              color: palette.inkMuted,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label, style: context.text.titleSmall),
                  const SizedBox(height: AppDimens.space4),
                  Text(method.description, style: context.text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
