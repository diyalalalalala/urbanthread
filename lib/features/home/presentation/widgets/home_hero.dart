import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// The block at the top of the storefront: a greeting and the season's line.
///
/// Text-only, and that is deliberate. A full-bleed hero image is the single
/// heaviest thing a landing screen can open with, and this app has to render
/// on a cold cache with no connection — an editorial type treatment costs
/// nothing to load and never shows a broken frame.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key, this.userName, this.onShopAll});

  /// The signed-in customer's name, or null when browsing signed out.
  final String? userName;

  final VoidCallback? onShopAll;

  /// Greets by clock rather than by session, so a signed-out visitor gets a
  /// warm opening line too instead of a conspicuous blank.
  static String greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final greeting = greetingFor(DateTime.now());
    // Only the first name: a full legal name in a greeting reads like a
    // billing statement.
    final firstName = userName?.trim().split(RegExp(r'\s+')).firstOrNull;

    return Container(
      width: double.infinity,
      color: palette.surfaceRaised,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pageGutter,
        AppDimens.space32,
        AppDimens.pageGutter,
        AppDimens.space32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstName == null || firstName.isEmpty
                ? greeting.toUpperCase()
                : '$greeting, $firstName'.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(color: palette.inkSubtle),
          ),
          const SizedBox(height: AppDimens.space16),
          Text(
            'Considered pieces,\nbuilt to last.',
            style: context.text.displaySmall,
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            'New season staples, chosen for how they wear rather than how '
            'loudly they arrive.',
            style: context.text.bodyMedium?.copyWith(color: palette.inkMuted),
          ),
          if (onShopAll != null) ...[
            const SizedBox(height: AppDimens.space24),
            FilledButton(
              onPressed: onShopAll,
              child: const Text('SHOP THE COLLECTION'),
            ),
          ],
        ],
      ),
    );
  }
}
