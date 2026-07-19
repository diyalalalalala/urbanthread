import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// Shared chrome for the auth screens.
///
/// All five (login, register, forgot, reset, verify) are a wordmark, a
/// heading, a form and a footer link. Factoring that out keeps them
/// visually identical, which matters more here than elsewhere — these
/// screens are where a user decides whether the app looks trustworthy.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.footer,
    this.showBackButton = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        title: Text('URBANTHREAD', style: AppTypography.wordmark.copyWith(
          fontSize: 15,
          letterSpacing: 4.5,
          color: context.palette.ink,
        )),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            // Keeps the footer pinned to the bottom on a tall screen while
            // still scrolling once the keyboard shrinks the viewport.
            padding: EdgeInsets.only(
              left: AppDimens.pageGutter,
              right: AppDimens.pageGutter,
              top: AppDimens.space32,
              bottom: AppDimens.space24 + context.keyboardInset,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight -
                    AppDimens.space32 -
                    AppDimens.space24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: context.text.displaySmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppDimens.space12),
                    Text(subtitle!, style: context.text.bodyMedium?.copyWith(
                      color: context.palette.inkMuted,
                    )),
                  ],
                  const SizedBox(height: AppDimens.space32),
                  child,
                  if (footer != null) ...[
                    const Spacer(),
                    const SizedBox(height: AppDimens.space32),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The error strip shown above a form after a failed submit.
///
/// Field-level messages are attached to their inputs; this carries the
/// summary the backend sent, which is often the only explanation available
/// (a 401 on login has no field to blame).
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppDimens.space20),
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: context.palette.dangerSubtle,
          borderRadius: AppDimens.borderRadius,
          border: Border.all(color: context.palette.danger.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              size: 18,
              color: context.palette.danger,
            ),
            const SizedBox(width: AppDimens.space8),
            Expanded(
              child: Text(
                message,
                style: context.text.bodySmall?.copyWith(
                  color: context.palette.danger,
                ),
              ),
            ),
          ],
        ),
      );
}
