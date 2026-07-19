import 'package:flutter/material.dart';

import '../errors/failures.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// The three screen-level states every async view needs, styled once.
///
/// Having a single [FailureView] matters more than it looks: it is where the
/// distinction between "offline" and "broken" gets expressed. An offline
/// failure offers *Retry* and says the data may be stale; a server failure
/// says something different. Left to individual screens, that nuance
/// collapses into a generic "Something went wrong" everywhere.

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            if (message != null) ...[
              const SizedBox(height: AppDimens.space16),
              Text(message!, style: context.text.bodySmall),
            ],
          ],
        ),
      );
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.title,
    super.key,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: context.palette.inkSubtle),
              const SizedBox(height: AppDimens.space20),
              Text(
                title,
                style: context.text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppDimens.space8),
                Text(
                  message!,
                  style: context.text.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppDimens.space24),
                OutlinedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!.toUpperCase()),
                ),
              ],
            ],
          ),
        ),
      );
}

class FailureView extends StatelessWidget {
  const FailureView({required this.failure, super.key, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isOffline = failure is NetworkFailure || failure is TimeoutFailure;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_outlined : Icons.error_outline,
              size: 44,
              color: isOffline
                  ? context.palette.inkSubtle
                  : context.palette.danger,
            ),
            const SizedBox(height: AppDimens.space20),
            Text(
              isOffline ? 'You are offline' : 'Something went wrong',
              style: context.text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              failure.message,
              style: context.text.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimens.space24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('TRY AGAIN'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A slim strip pinned under the app bar while the device is offline.
///
/// Deliberately non-blocking: cached catalogue, cart and wishlist all stay
/// usable without a connection, so this informs rather than interrupts.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: context.palette.warningSubtle,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.pageGutter,
          vertical: AppDimens.space8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 14,
              color: context.palette.warning,
            ),
            const SizedBox(width: AppDimens.space8),
            Text(
              'OFFLINE — SHOWING SAVED ITEMS',
              style: AppTypography.eyebrow.copyWith(
                color: context.palette.warning,
              ),
            ),
          ],
        ),
      );
}
