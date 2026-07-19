import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../domain/entities/address_draft.dart';

/// The add/edit address form, presented as a bottom sheet.
///
/// Field names mirror the API one-for-one, deliberately: the street line is
/// **`street`** — a single field, not `line1`/`line2` — and only `fullName`,
/// `phone`, `street` and `city` are required. Anything the form invented here
/// would be dropped by the validator without complaint.
class AddressFormSheet extends StatefulWidget {
  const AddressFormSheet({super.key, this.initial, this.isFirstAddress = false});

  /// Null when adding, populated when editing.
  final Address? initial;

  /// The first address a customer saves becomes their default server-side
  /// regardless of the checkbox, so the checkbox is hidden rather than
  /// offering a choice that will be overruled.
  final bool isFirstAddress;

  /// Opens the sheet and resolves to the completed draft, or null if
  /// dismissed.
  static Future<AddressDraft?> show(
    BuildContext context, {
    Address? initial,
    bool isFirstAddress = false,
  }) =>
      showModalBottomSheet<AddressDraft>(
        context: context,
        isScrollControlled: true,
        builder: (_) => AddressFormSheet(
          initial: initial,
          isFirstAddress: isFirstAddress,
        ),
      );

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _label;
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _street;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _postalCode;
  late final TextEditingController _country;
  late final TextEditingController _landmark;

  late AddressType _type;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;

    _label = TextEditingController(text: initial?.label ?? 'Home');
    _fullName = TextEditingController(text: initial?.fullName ?? '');
    _phone = TextEditingController(text: initial?.phone ?? '');
    _street = TextEditingController(text: initial?.street ?? '');
    _city = TextEditingController(text: initial?.city ?? '');
    _state = TextEditingController(text: initial?.state ?? '');
    _postalCode = TextEditingController(text: initial?.postalCode ?? '');
    // Nepal is the backend's own default, so pre-filling it matches what the
    // server would have stored anyway.
    _country = TextEditingController(text: initial?.country ?? 'Nepal');
    _landmark = TextEditingController(text: initial?.landmark ?? '');

    _type = initial?.type ?? AddressType.home;
    _isDefault = initial?.isDefault ?? widget.isFirstAddress;
  }

  @override
  void dispose() {
    for (final controller in [
      _label,
      _fullName,
      _phone,
      _street,
      _city,
      _state,
      _postalCode,
      _country,
      _landmark,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return Padding(
      // Lifts the sheet clear of the keyboard so the focused field stays
      // visible while typing.
      padding: EdgeInsets.only(bottom: context.keyboardInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppDimens.pageGutter),
            children: [
              Text(
                isEditing ? 'Edit address' : 'New address',
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: AppDimens.space20),

              _field(
                controller: _fullName,
                label: 'Recipient name',
                required: true,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 2) return 'At least 2 characters';
                  if (text.length > 80) return 'At most 80 characters';
                  return null;
                },
              ),
              _field(
                controller: _phone,
                label: 'Phone number',
                required: true,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'A phone number is required';
                  // Matches the backend's own pattern, which accepts both
                  // +9779812345678 and 01-4567890.
                  if (!RegExp(r'^[+]?[\d\s().-]{7,20}$').hasMatch(text)) {
                    return 'That does not look like a phone number';
                  }
                  return null;
                },
              ),
              _field(
                controller: _street,
                label: 'Street address',
                required: true,
                textCapitalization: TextCapitalization.words,
                maxLines: 2,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'A street address is required'
                    : null,
              ),
              _field(
                controller: _landmark,
                label: 'Landmark (optional)',
                textCapitalization: TextCapitalization.words,
              ),
              _field(
                controller: _city,
                label: 'City',
                required: true,
                textCapitalization: TextCapitalization.words,
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? 'A city is required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _state,
                      label: 'Province (optional)',
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: _field(
                      controller: _postalCode,
                      label: 'Postal code (optional)',
                    ),
                  ),
                ],
              ),
              _field(
                controller: _country,
                label: 'Country',
                textCapitalization: TextCapitalization.words,
              ),
              _field(
                controller: _label,
                label: 'Label',
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: AppDimens.space8),
              Text('Address type', style: context.text.titleSmall),
              const SizedBox(height: AppDimens.space8),
              Wrap(
                spacing: AppDimens.space8,
                children: [
                  for (final type in AddressType.values)
                    ChoiceChip(
                      label: Text(type.label),
                      selected: _type == type,
                      onSelected: (_) => setState(() => _type = type),
                    ),
                ],
              ),

              if (!widget.isFirstAddress) ...[
                const SizedBox(height: AppDimens.space8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _isDefault,
                  onChanged: (value) =>
                      setState(() => _isDefault = value ?? false),
                  title: const Text('Use as my default address'),
                ),
              ],

              const SizedBox(height: AppDimens.space20),
              FilledButton(
                onPressed: _submit,
                child: Text(isEditing ? 'SAVE CHANGES' : 'SAVE ADDRESS'),
              ),
              const SizedBox(height: AppDimens.space12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.space12),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
          ),
        ),
      );

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      AddressDraft(
        label: _label.text.trim().isEmpty ? 'Home' : _label.text.trim(),
        type: _type,
        fullName: _fullName.text.trim(),
        phone: _phone.text.trim(),
        street: _street.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        postalCode: _postalCode.text.trim(),
        country: _country.text.trim().isEmpty ? 'Nepal' : _country.text.trim(),
        landmark: _landmark.text.trim(),
        // The first address is made default by the server whatever this says.
        isDefault: _isDefault || widget.isFirstAddress,
      ),
    );
  }
}
