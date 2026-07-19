import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../authentication/domain/usecases/change_password_usecase.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';

/// Changes the account password.
///
/// A successful change bumps the account's `tokenVersion` server-side, which
/// revokes **every** existing token — including this device's. There is no
/// refresh endpoint to recover with, so the only honest ending is to sign out
/// locally and send the user back to login; leaving them on a dead token would
/// surface as a confusing 401 on their next tap.
class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  ValidationFailure? _fieldErrors;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Change password')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.pageGutter),
            children: [
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Current password',
                  errorText: _fieldErrors?.forField('currentPassword'),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Enter your current password.'
                    : null,
              ),
              const SizedBox(height: AppDimens.space20),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'New password',
                  helperText:
                      'At least 8 characters, with an upper case letter, a '
                      'lower case letter and a digit.',
                  helperMaxLines: 3,
                  errorText: _fieldErrors?.forField('newPassword'),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: _validateNewPassword,
              ),
              const SizedBox(height: AppDimens.space20),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                ),
                validator: (value) => value == _newController.text
                    ? null
                    : 'The two passwords do not match.',
              ),
              const SizedBox(height: AppDimens.space24),
              Container(
                padding: const EdgeInsets.all(AppDimens.space12),
                decoration: BoxDecoration(
                  color: context.palette.infoSubtle,
                  borderRadius: AppDimens.borderRadius,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: context.palette.info,
                    ),
                    const SizedBox(width: AppDimens.space8),
                    Expanded(
                      child: Text(
                        'Changing your password signs you out on every device, '
                        'including this one.',
                        style: context.text.bodySmall?.copyWith(
                          color: context.palette.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.space32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'UPDATING…' : 'UPDATE PASSWORD'),
              ),
            ],
          ),
        ),
      );

  String? _validateNewPassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) {
      return 'Use at least 8 characters.';
    }
    if (!RegExp('[A-Z]').hasMatch(password)) {
      return 'Include an upper case letter.';
    }
    if (!RegExp('[a-z]').hasMatch(password)) {
      return 'Include a lower case letter.';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Include a digit.';
    }
    if (password == _currentController.text) {
      return 'Choose a password you have not used here before.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
      _fieldErrors = null;
    });

    final result = await ref.read(changePasswordUseCaseProvider)(
      ChangePasswordParams(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      ),
    );

    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure != null) {
      setState(() {
        _isSaving = false;
        _fieldErrors = failure is ValidationFailure ? failure : null;
      });
      context.showSnack(failure.message, isError: true);
      return;
    }

    // The token this device holds is already dead. `logout()` clears it
    // locally and tolerates the server call failing, which it will.
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;

    context.showSnack('Password updated. Please sign in again.');
  }
}
