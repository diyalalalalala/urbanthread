import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_scaffold.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.redirectTo});

  /// Where to land after signing in. Set by the router when an unauthenticated
  /// user is bounced off a guarded route, so they resume what they were doing
  /// instead of being dropped on the home screen.
  final String? redirectTo;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final signedIn = await ref.read(authProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted || !signedIn) return;
    context.go(widget.redirectTo ?? AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final validation = state.validationFailure;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to your UrbanThread account.',
      showBackButton: false,
      footer: _SignUpPrompt(redirectTo: widget.redirectTo),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shown only when the failure has no field to attach to — a bad
            // password comes back as a bare 401 with no `errors` array.
            if (state.failure != null && validation == null)
              AuthErrorBanner(message: state.failure!.message),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
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
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
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
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validators.loginPassword,
              onFieldSubmitted: (_) => _submit(),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: const Text('FORGOT PASSWORD?'),
              ),
            ),
            const SizedBox(height: AppDimens.space16),

            ElevatedButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: state.isSubmitting
                  ? const _ButtonSpinner()
                  : const Text('SIGN IN'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({this.redirectTo});

  final String? redirectTo;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to UrbanThread?',
            style: context.text.bodySmall,
          ),
          TextButton(
            onPressed: () => context.push(
              AppRoutes.register,
              extra: redirectTo,
            ),
            child: const Text('CREATE ACCOUNT'),
          ),
        ],
      );
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.palette.canvas,
        ),
      );
}
