import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onClose!();
      },
      child: scaffold,
    );
  }
}

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
