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
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final bool showBackButton;

  /// Dismisses the screen when there is no route beneath it to pop back to.
  ///
  /// The router *replaces* the stack when it bounces a guest off a guarded
  /// route, so the sign-in screen it lands on has no back arrow to offer and
  /// would otherwise be a dead end — the only way out being the gesture that
  /// closes the app.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        leading: onClose == null
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                tooltip: 'Close',
              ),
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
                minHeight: (constraints.maxHeight -
                        AppDimens.space32 -
                        AppDimens.space24)
                    .clamp(0.0, double.infinity),
              ),
              // The scroll view offers unbounded height, which the `Spacer`
              // below cannot resolve against. IntrinsicHeight tightens the
              // column to its natural height first, so the footer still gets
              // pushed to the bottom of the viewport on a tall screen.
              child: IntrinsicHeight(
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
      ),
    );

    if (onClose == null) return scaffold;

    // The system back gesture is given the same meaning as the close button,
    // so the two cannot disagree. Without this, back on a screen the router
    // arrived at by replacement has no route to pop and closes the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onClose!();
      },
      child: scaffold,
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
