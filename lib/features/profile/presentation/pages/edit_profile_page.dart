import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/state_views.dart';
import '../providers/profile_notifier.dart';
import '../widgets/failure_from_error.dart';

/// Edits the only two fields `PATCH /users/me` accepts.
///
/// Email and role are shown read-only rather than omitted: the validator
/// silently discards them, so an editable field would look like it worked and
/// change nothing.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  /// The validator's own pattern, mirrored so a bad phone is caught before a
  /// round trip.
  static final _phonePattern = RegExp(r'^[+]?[\d\s().-]{7,20}$');

  bool _isSaving = false;
  bool _seeded = false;
  ValidationFailure? _fieldErrors;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    // Seeded once, from the first successful load. Re-seeding on every build
    // would fight the user's typing whenever the profile refreshed.
    if (!_seeded && profile.hasValue) {
      _nameController.text = profile.value!.name;
      _phoneController.text = profile.value!.phone;
      _seeded = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: switch (profile) {
        AsyncData(:final value) => Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.pageGutter),
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Full name',
                    errorText: _fieldErrors?.forField('name'),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.length < 2 || trimmed.length > 80) {
                      return 'Your name must be 2 to 80 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.space20),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                    helperText: 'Optional. Digits, spaces and + ( ) . -',
                    errorText: _fieldErrors?.forField('phone'),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return null;
                    if (!_phonePattern.hasMatch(trimmed)) {
                      return 'That does not look like a phone number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.space24),
                _ReadOnlyRow(label: 'Email', value: value.email),
                const SizedBox(height: AppDimens.space8),
                Text(
                  'Your email address cannot be changed here.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.palette.inkSubtle,
                  ),
                ),
                const SizedBox(height: AppDimens.space32),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'SAVING…' : 'SAVE CHANGES'),
                ),
              ],
            ),
          ),
        AsyncError(:final error) => FailureView(
            failure: failureFrom(error),
            onRetry: () => ref.invalidate(profileProvider),
          ),
        _ => const LoadingView(),
      },
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final current = ref.read(profileProvider).value;
    if (current == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    // Only changed fields are sent. Sending both unchanged is still a valid
    // request, but sending nothing at all is a 400 — so an untouched form is
    // treated as "nothing to do" here rather than round-tripped.
    final nextName = name == current.name ? null : name;
    final nextPhone = phone == current.phone ? null : phone;

    if (nextName == null && nextPhone == null) {
      context.showSnack('Nothing to save.');
      return;
    }

    setState(() {
      _isSaving = true;
      _fieldErrors = null;
    });

    final failure = await ref.read(profileProvider.notifier).updateProfile(
          name: nextName,
          phone: nextPhone,
        );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _fieldErrors = failure is ValidationFailure ? failure : null;
    });

    if (failure == null) {
      context.showSnack('Profile updated.');
      Navigator.of(context).maybePop();
    } else {
      context.showSnack(failure.message, isError: true);
    }
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: context.palette.surfaceSunken,
          borderRadius: AppDimens.borderRadius,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: context.palette.inkSubtle,
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Text(
                value,
                style: context.text.bodyMedium,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
}
