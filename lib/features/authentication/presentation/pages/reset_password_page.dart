import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_scaffold.dart';

/// Reached from the emailed link, `/reset-password/<token>`.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({required this.token, super.key});

  final String token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await ref.read(authProvider.notifier).resetPassword(
          token: widget.token,
          password: _passwordController.text,
        );
    if (!mounted) return;

    switch (result) {
      case Success():
        // The reset bumped `tokenVersion` server-side, so every session for
        // this account — including any this device still held — is now dead.
        // Going anywhere but login would just bounce off a 401.
        context.showSnack('Password updated. Please sign in.');
        context.go(AppRoutes.login);
      case FailureResult(:final failure):
        setState(() {
          _isSubmitting = false;
          _error = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Set a new password',
      subtitle: 'Choose a password you have not used before.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A used or expired token fails here, not on the previous screen.
            if (_error != null) AuthErrorBanner(message: _error!),

            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New password',
                helperText:
                    'At least 8 characters, with a capital and a number',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.password,
            ),
            const SizedBox(height: AppDimens.space16),

            TextFormField(
              controller: _confirmController,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
              ),
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              validator: (value) => Validators.confirmPassword(
                value,
                _passwordController.text,
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppDimens.space24),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.palette.canvas,
                      ),
                    )
                  : const Text('UPDATE PASSWORD'),
            ),
          ],
        ),
      ),
    );
  }
}
