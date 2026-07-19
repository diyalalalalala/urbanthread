import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_scaffold.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final created = await ref.read(authProvider.notifier).register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
        );

    if (!mounted || !created) return;

    // The account is usable straight away, but checkout and reviews stay
    // closed until the address is verified — so say so rather than letting
    // the user discover it at the checkout button.
    context.showSnack(
      'Account created. Check your email to verify your address.',
    );
    context.go(widget.redirectTo ?? AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final validation = state.validationFailure;

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Join UrbanThread to shop, save and track your orders.',
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account?', style: context.text.bodySmall),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('SIGN IN'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.failure != null && validation == null)
              AuthErrorBanner(message: state.failure!.message),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full name',
                errorText: validation?.forField('name'),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.name,
            ),
            const SizedBox(height: AppDimens.space16),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
                // A duplicate address comes back as a 409 whose message is
                // already user-facing; a 422 attaches it to this field.
                errorText: validation?.forField('email'),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              validator: Validators.email,
            ),
            const SizedBox(height: AppDimens.space16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone (optional)',
                hintText: '+977 98XXXXXXXX',
                errorText: validation?.forField('phone'),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: (value) => Validators.phone(value),
            ),
            const SizedBox(height: AppDimens.space16),

            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters, with a capital and a number',
                errorText: validation?.forField('password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.password,
            ),
            const SizedBox(height: AppDimens.space16),

            TextFormField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: 'Confirm password'),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: (value) => Validators.confirmPassword(
                value,
                _passwordController.text,
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppDimens.space24),

            ElevatedButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: state.isSubmitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.palette.canvas,
                      ),
                    )
                  : const Text('CREATE ACCOUNT'),
            ),
          ],
        ),
      ),
    );
  }
}
