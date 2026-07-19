import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../providers/profile_notifier.dart';
import '../widgets/account_tile.dart';
import '../widgets/avatar_picker_sheet.dart';
import '../widgets/failure_from_error.dart';
import '../widgets/profile_avatar.dart';

/// The account hub: identity, verification state, and the way into every
/// other account screen.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  /// Avatar work has its own flag rather than dropping the whole profile to a
  /// spinner — the upload takes seconds and the rest of the page stays valid
  /// throughout.
  bool _isAvatarBusy = false;
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          const NotificationBell(),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: switch (profile) {
        AsyncData(:final value) => RefreshIndicator(
            onRefresh: () => ref.read(profileProvider.notifier).refresh(),
            child: _ProfileBody(
              user: value,
              isAvatarBusy: _isAvatarBusy,
              isResending: _isResending,
              onChangeAvatar: _changeAvatar,
              onRemoveAvatar: _removeAvatar,
              onResendVerification: () => _resendVerification(value.email),
            ),
          ),
        AsyncError(:final error) => FailureView(
            failure: failureFrom(error),
            onRetry: () => ref.invalidate(profileProvider),
          ),
        _ => const LoadingView(),
      },
    );
  }

  Future<void> _changeAvatar() async {
    final path = await pickAvatarPath(context);
    if (path == null) return;

    setState(() => _isAvatarBusy = true);
    final failure = await ref.read(profileProvider.notifier).uploadAvatar(path);
    if (!mounted) return;

    setState(() => _isAvatarBusy = false);
    context.showSnack(
      failure?.message ?? 'Photo updated.',
      isError: failure != null,
    );
  }

  Future<void> _removeAvatar() async {
    setState(() => _isAvatarBusy = true);
    final failure = await ref.read(profileProvider.notifier).removeAvatar();
    if (!mounted) return;

    setState(() => _isAvatarBusy = false);
    context.showSnack(
      failure?.message ?? 'Photo removed.',
      isError: failure != null,
    );
  }

  /// Re-sends the confirmation email through the authentication feature's own
  /// use case — there is no profile-scoped endpoint for it.
  Future<void> _resendVerification(String email) async {
    setState(() => _isResending = true);
    final result = await ref.read(resendVerificationUseCaseProvider)(email);
    if (!mounted) return;

    setState(() => _isResending = false);
    // The backend's message is deliberately vague and must be shown verbatim
    // rather than replaced with a guess.
    context.showSnack(
      switch (result) {
        Success(:final value) => value,
        FailureResult(:final failure) => failure.message,
      },
      isError: result.isFailure,
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.user,
    required this.isAvatarBusy,
    required this.isResending,
    required this.onChangeAvatar,
    required this.onRemoveAvatar,
    required this.onResendVerification,
  });

  final User user;
  final bool isAvatarBusy;
  final bool isResending;
  final Future<void> Function() onChangeAvatar;
  final Future<void> Function() onRemoveAvatar;
  final Future<void> Function() onResendVerification;

  @override
  Widget build(BuildContext context) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppDimens.space40),
        children: [
          _Header(
            user: user,
            isBusy: isAvatarBusy,
            onChangeAvatar: onChangeAvatar,
            onRemoveAvatar: onRemoveAvatar,
          ),
          if (!user.isEmailVerified)
            _VerificationNotice(
              isSending: isResending,
              onResend: onResendVerification,
            ),
          const AccountSectionHeader('Shopping'),
          AccountTile(
            icon: Icons.receipt_long_outlined,
            label: 'My orders',
            subtitle: 'Track, return or reorder',
            onTap: () => context.push(AppRoutes.orders),
          ),
          AccountTile(
            icon: Icons.favorite_border,
            label: 'Wishlist',
            onTap: () => context.push(AppRoutes.wishlist),
          ),
          AccountTile(
            icon: Icons.location_on_outlined,
            label: 'Addresses',
            subtitle: user.hasAddresses
                ? '${user.addresses.length} saved'
                : 'None saved yet',
            onTap: () => context.push(AppRoutes.addresses),
          ),
          AccountTile(
            icon: Icons.rate_review_outlined,
            label: 'My reviews',
            onTap: () => context.push(AppRoutes.myReviews),
          ),
          AccountTile(
            icon: Icons.history,
            label: 'Recently viewed',
            onTap: () => context.push(AppRoutes.recentlyViewed),
          ),
          const AccountSectionHeader('Account'),
          AccountTile(
            icon: Icons.person_outline,
            label: 'Edit profile',
            subtitle: 'Name and phone number',
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          AccountTile(
            icon: Icons.lock_outline,
            label: 'Change password',
            onTap: () => context.push(AppRoutes.changePassword),
          ),
          AccountTile(
            icon: Icons.notifications_none,
            label: 'Notifications',
            onTap: () => context.push(AppRoutes.notifications),
          ),
          AccountTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            subtitle: 'Appearance, storage and sign out',
            onTap: () => context.push(AppRoutes.settings),
          ),
        ],
      );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.isBusy,
    required this.onChangeAvatar,
    required this.onRemoveAvatar,
  });

  final User user;
  final bool isBusy;
  final Future<void> Function() onChangeAvatar;
  final Future<void> Function() onRemoveAvatar;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(AppDimens.pageGutter),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.line)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ProfileAvatar(
                initials: user.initials,
                imageUrl: user.avatarUrl,
              ),
              if (isBusy)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: context.text.titleMedium),
                const SizedBox(height: AppDimens.space2),
                Text(
                  user.email,
                  style: context.text.bodySmall?.copyWith(
                    color: palette.inkMuted,
                  ),
                ),
                if (user.phone.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.space2),
                  Text(
                    user.phone,
                    style: context.text.bodySmall?.copyWith(
                      color: palette.inkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimens.space8),
                Wrap(
                  spacing: AppDimens.space8,
                  children: [
                    TextButton(
                      onPressed: isBusy ? null : onChangeAvatar,
                      child: Text(
                        user.avatarUrl == null ? 'ADD PHOTO' : 'CHANGE PHOTO',
                      ),
                    ),
                    // Only offered when there is one — `DELETE
                    // /users/me/avatar` answers 400 when there is not.
                    if (user.avatarUrl != null)
                      TextButton(
                        onPressed: isBusy ? null : onRemoveAvatar,
                        style: TextButton.styleFrom(
                          foregroundColor: palette.danger,
                        ),
                        child: const Text('REMOVE'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains what an unverified address blocks, and offers the fix.
///
/// Shown rather than letting the customer discover it as a 403 the first time
/// they try to check out or write a review.
class _VerificationNotice extends StatelessWidget {
  const _VerificationNotice({required this.isSending, required this.onResend});

  final bool isSending;
  final Future<void> Function() onResend;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimens.pageGutter,
        AppDimens.space16,
        AppDimens.pageGutter,
        0,
      ),
      padding: const EdgeInsets.all(AppDimens.space12),
      decoration: BoxDecoration(
        color: palette.warningSubtle,
        borderRadius: AppDimens.borderRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.mark_email_unread_outlined, size: 20, color: palette.warning),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm your email address',
                  style: context.text.titleSmall?.copyWith(
                    color: palette.warning,
                  ),
                ),
                const SizedBox(height: AppDimens.space4),
                Text(
                  'Checkout and writing reviews stay locked until you open '
                  'the link we sent you.',
                  style: context.text.bodySmall?.copyWith(
                    color: palette.warning,
                  ),
                ),
                const SizedBox(height: AppDimens.space8),
                OutlinedButton(
                  onPressed: isSending ? null : onResend,
                  child: Text(isSending ? 'SENDING…' : 'RESEND EMAIL'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
