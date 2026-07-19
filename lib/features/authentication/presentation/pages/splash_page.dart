import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// Shown only while the session is [AuthStatus.unknown] — that is, when a
/// token exists but `/auth/me` has not answered yet and there is no cached
/// profile to render optimistically.
///
/// In the common case the cached profile means the app opens straight onto
/// the home screen and this is never seen. Keeping it deliberately plain
/// avoids a branded animation that would draw attention to a delay most
/// users never experience.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'URBANTHREAD',
                style: AppTypography.wordmark.copyWith(
                  color: context.palette.ink,
                ),
              ),
              const SizedBox(height: AppDimens.space32),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.palette.accent,
                ),
              ),
            ],
          ),
        ),
      );
}
