import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// The block at the top of the storefront: a greeting and the season's line.
///
/// Featuring a full-bleed hero image background.
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
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        image: const DecorationImage(
          image: AssetImage('assets/images/hero.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  palette.surfaceRaised.withValues(alpha: 0.95),
                  palette.surfaceRaised.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.75],
              ),
            ),
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
                  style: AppTypography.eyebrow.copyWith(color: palette.ink),
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
                  style: context.text.bodyMedium?.copyWith(color: palette.ink),
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
          ),
        ),
      ),
    );
  }
}
