import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../authentication/domain/entities/user.dart';

/// The address book as a radio list.
///
/// What is selected here is an **id**, which is the whole point: `POST
/// /orders` takes `shippingAddressId` and looks the address up on the user
/// document itself. There is no way to pass a one-off address, so an empty
/// book has to be filled before an order can be placed — hence the "add"
/// affordance living inside checkout rather than only in account settings.
class AddressSelector extends StatelessWidget {
  const AddressSelector({
    required this.addresses,
    required this.selectedId,
    required this.onSelected,
    super.key,
    this.onAddPressed,
    this.onEdit,
  });

  final List<Address> addresses;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final VoidCallback? onAddPressed;
  final ValueChanged<Address>? onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (addresses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.space20),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(color: palette.line),
          borderRadius: AppDimens.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No saved addresses', style: context.text.titleSmall),
            const SizedBox(height: AppDimens.space4),
            Text(
              'We need somewhere to send your parcel before you can order.',
              style: context.text.bodySmall,
            ),
            const SizedBox(height: AppDimens.space16),
            FilledButton(
              onPressed: onAddPressed,
              child: const Text('ADD AN ADDRESS'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final address in addresses)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.space8),
            child: _AddressTile(
              address: address,
              isSelected: address.id == selectedId,
              onTap: () => onSelected(address.id),
              onEdit: onEdit == null ? null : () => onEdit!(address),
            ),
          ),
        if (onAddPressed != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('ADD A NEW ADDRESS'),
            ),
          ),
      ],
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
  });

  final Address address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

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
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
            ),
            const SizedBox(width: AppDimens.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(address.fullName, style: context.text.titleSmall),
                      const SizedBox(width: AppDimens.space8),
                      _Tag(label: address.type.label),
                      if (address.isDefault) ...[
                        const SizedBox(width: AppDimens.space4),
                        _Tag(label: 'Default', highlighted: true),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Text(address.singleLine, style: context.text.bodySmall),
                  const SizedBox(height: AppDimens.space2),
                  Text(address.phone, style: context.text.bodySmall),
                ],
              ),
            ),
            if (onEdit != null)
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
              ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.highlighted = false});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space8,
        vertical: AppDimens.space2,
      ),
      decoration: BoxDecoration(
        color: highlighted ? palette.accentSubtle : palette.surfaceSunken,
        borderRadius: AppDimens.borderRadiusSm,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.eyebrow.copyWith(
          fontSize: 9,
          color: highlighted ? palette.accent : palette.inkMuted,
        ),
      ),
    );
  }
}
