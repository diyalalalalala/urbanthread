import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  String? _confirmation;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await ref.read(forgotPasswordUseCaseProvider)(
      _emailController.text,
    );
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      switch (result) {
        // The server's message is shown verbatim. It is deliberately
        // non-committal ("If an account exists for that address…") so the
        // endpoint cannot be used to discover which addresses are
        // registered — a friendlier, more definite string would leak exactly
        // what the wording withholds.
        case Success(:final value):
          _confirmation = value;
        case FailureResult(:final failure):
          _error = failure.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      subtitle: _confirmation == null
          ? 'Enter your email and we will send you a reset link.'
          : null,
      child: _confirmation != null
          ? _ConfirmationPanel(message: _confirmation!)
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) AuthErrorBanner(message: _error!),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    validator: Validators.email,
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
                        : const Text('SEND RESET LINK'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ConfirmationPanel extends StatelessWidget {
  const _ConfirmationPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppDimens.space20),
        decoration: BoxDecoration(
          color: context.palette.successSubtle,
          borderRadius: AppDimens.borderRadius,
        ),
        child: Column(
          children: [
            Icon(
              Icons.mark_email_read_outlined,
              size: 32,
              color: context.palette.success,
            ),
            const SizedBox(height: AppDimens.space16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.palette.success,
              ),
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              'The link expires shortly, so use it soon.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
          ],
        ),
      );
}
