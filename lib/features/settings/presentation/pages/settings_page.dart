import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/usecase.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../domain/entities/theme_preference.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_tile.dart';

/// Appearance, storage, and the ways out of the account.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final searchTerms = ref.watch(searchHistoryCountProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppDimens.space40),
        children: [
          const SettingsSectionHeader('Appearance'),
          // Compared against the provider's ThemeMode rather than a second
          // copy of the preference, so the list can never disagree with what
          // MaterialApp is actually rendering.
          for (final preference in ThemePreference.values)
            SettingsTile(
              icon: _themeIcon(preference),
              label: preference.label,
              subtitle: preference.description,
              showChevron: false,
              trailing: _preferenceFor(themeMode) == preference
                  ? Icon(Icons.check, size: 20, color: context.palette.accent)
                  : null,
              onTap: () =>
                  ref.read(themeModeProvider.notifier).select(preference),
            ),
          const SettingsSectionHeader('Account'),
          if (user != null)
            SettingsTile(
              icon: Icons.person_outline,
              label: user.name,
              subtitle: user.email,
              onTap: () => context.push(AppRoutes.editProfile),
            ),
          SettingsTile(
            icon: Icons.location_on_outlined,
            label: 'Addresses',
            onTap: () => context.push(AppRoutes.addresses),
          ),
          SettingsTile(
            icon: Icons.lock_outline,
            label: 'Change password',
            onTap: () => context.push(AppRoutes.changePassword),
          ),
          SettingsTile(
            icon: Icons.rate_review_outlined,
            label: 'My reviews',
            onTap: () => context.push(AppRoutes.myReviews),
          ),
          SettingsTile(
            icon: Icons.notifications_none,
            label: 'Notifications',
            onTap: () => context.push(AppRoutes.notifications),
          ),
          const SettingsSectionHeader('Storage'),
          SettingsTile(
            icon: Icons.cleaning_services_outlined,
            label: 'Clear cached catalogue',
            subtitle: 'Frees up space. Products will download again.',
            onTap: _clearCache,
          ),
          SettingsTile(
            icon: Icons.search_off_outlined,
            label: 'Clear search history',
            subtitle: searchTerms == 0
                ? 'Nothing saved'
                : '$searchTerms saved ${searchTerms == 1 ? 'search' : 'searches'}',
            onTap: searchTerms == 0 ? _nothingToClear : _clearSearchHistory,
          ),
          const SettingsSectionHeader('Session'),
          SettingsTile(
            icon: Icons.logout,
            label: 'Sign out',
            isDestructive: true,
            onTap: _isSigningOut ? _busy : _signOut,
          ),
          SettingsTile(
            icon: Icons.devices_other_outlined,
            label: 'Sign out everywhere',
            subtitle: 'Ends every session on every device',
            isDestructive: true,
            onTap: _isSigningOut ? _busy : _signOutEverywhere,
          ),
          const SizedBox(height: AppDimens.space32),
          Center(
            child: Text(
              'UrbanThread $_appVersion',
              style: context.text.bodySmall?.copyWith(
                color: context.palette.inkSubtle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kept in step with `pubspec.yaml` by hand.
  ///
  /// `package_info_plus` is not a dependency of this project and core exposes
  /// no version constant, so there is nothing to read it from at runtime.
  static const _appVersion = '1.0.0 (1)';

  IconData _themeIcon(ThemePreference preference) => switch (preference) {
        ThemePreference.system => Icons.brightness_auto_outlined,
        ThemePreference.light => Icons.light_mode_outlined,
        ThemePreference.dark => Icons.dark_mode_outlined,
      };

  ThemePreference _preferenceFor(ThemeMode mode) => switch (mode) {
        ThemeMode.light => ThemePreference.light,
        ThemeMode.dark => ThemePreference.dark,
        ThemeMode.system => ThemePreference.system,
      };

  void _busy() => context.showSnack('Signing out…');

  void _nothingToClear() => context.showSnack('There is nothing to clear.');

  Future<void> _clearCache() async {
    final confirmed = await _confirm(
      title: 'Clear cached catalogue?',
      message: 'Saved product data is removed from this device. Your cart, '
          'wishlist and orders are untouched.',
      confirmLabel: 'CLEAR',
    );
    if (confirmed != true || !mounted) return;

    final result = await ref.read(clearCatalogueCacheUseCaseProvider)(
      const NoParams(),
    );
    if (!mounted) return;

    final failure = result.failureOrNull;
    context.showSnack(
      failure?.message ?? 'Cached catalogue cleared.',
      isError: failure != null,
    );
  }

  Future<void> _clearSearchHistory() async {
    final failure = await ref.read(searchHistoryCountProvider.notifier).clear();
    if (!mounted) return;

    context.showSnack(
      failure?.message ?? 'Search history cleared.',
      isError: failure != null,
    );
  }

  Future<void> _signOut() async {
    final confirmed = await _confirm(
      title: 'Sign out?',
      message: 'Your cart and wishlist stay on your account.',
      confirmLabel: 'SIGN OUT',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);
    // Always succeeds locally, even offline — refusing would trap the user.
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    setState(() => _isSigningOut = false);
  }

  Future<void> _signOutEverywhere() async {
    final confirmed = await _confirm(
      title: 'Sign out everywhere?',
      message: 'Every device signed in to this account will be logged out, '
          'including this one.',
      confirmLabel: 'SIGN OUT ALL',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);
    // Unlike a plain sign-out this one is only meaningful if the server got
    // it, so a failure is reported rather than swallowed.
    final failure = await ref.read(authProvider.notifier).logoutEverywhere();
    if (!mounted) return;

    setState(() => _isSigningOut = false);
    if (failure != null) {
      context.showSnack(failure.message, isError: true);
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) =>
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: dialogContext.palette.danger,
              ),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
}
