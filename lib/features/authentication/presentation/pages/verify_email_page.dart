import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/state_views.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_scaffold.dart';

/// Reached from the emailed link, `/verify-email/<token>`.
///
/// Reachable whether or not there is a session — the link may well be opened
/// on a device that has never signed in, in which case verifying is all it
/// does and the user still has to log in afterwards.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({required this.token, super.key});

  final String token;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  Future<Failure?>? _verification;

  @override
  void initState() {
    super.initState();
    // Held in a field rather than called from `build` so a rebuild (a theme
    // change, a keyboard event) does not re-consume a single-use token.
    _verification = ref.read(authProvider.notifier).verifyEmail(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Verify email',
      showBackButton: false,
      child: FutureBuilder<Failure?>(
        future: _verification,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimens.space48),
              child: LoadingView(message: 'Confirming your address…'),
            );
          }

          final failure = snapshot.data;
          if (failure != null) return _VerificationFailed(failure: failure);
          return const _VerificationSucceeded();
        },
      ),
    );
  }
}

class _VerificationSucceeded extends ConsumerWidget {
  const _VerificationSucceeded();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(isAuthenticatedProvider);

    return Column(
      children: [
        Icon(
          Icons.verified_outlined,
          size: 44,
          color: context.palette.success,
        ),
        const SizedBox(height: AppDimens.space20),
        Text('Email verified', style: context.text.headlineSmall),
        const SizedBox(height: AppDimens.space8),
        Text(
          'Checkout and reviews are now unlocked on your account.',
          textAlign: TextAlign.center,
          style: context.text.bodySmall,
        ),
        const SizedBox(height: AppDimens.space32),
        ElevatedButton(
          onPressed: () =>
              context.go(isSignedIn ? AppRoutes.home : AppRoutes.login),
          child: Text(isSignedIn ? 'CONTINUE SHOPPING' : 'SIGN IN'),
        ),
      ],
    );
  }
}

class _VerificationFailed extends StatelessWidget {
  const _VerificationFailed({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(
            Icons.link_off_outlined,
            size: 44,
            color: context.palette.danger,
          ),
          const SizedBox(height: AppDimens.space20),
          Text('Link did not work', style: context.text.headlineSmall),
          const SizedBox(height: AppDimens.space8),
          Text(
            failure.message,
            textAlign: TextAlign.center,
            style: context.text.bodySmall,
          ),
          const SizedBox(height: AppDimens.space8),
          Text(
            'Verification links expire. Request a fresh one from your '
            'profile and try again.',
            textAlign: TextAlign.center,
            style: context.text.bodySmall,
          ),
          const SizedBox(height: AppDimens.space32),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('BACK TO SHOP'),
          ),
        ],
      );
}
