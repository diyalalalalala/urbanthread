import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/privacy_guard.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../providers/profile_notifier.dart';
import '../widgets/account_tile.dart';
import '../widgets/avatar_picker_sheet.dart';
import '../widgets/failure_from_error.dart';
import '../widgets/profile_avatar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isAvatarBusy = false;

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
      body: PrivacyGuard(
        label: 'Account details hidden',
        child: switch (profile) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () => ref.read(profileProvider.notifier).refresh(),
              child: _ProfileBody(
                user: value,
                isAvatarBusy: _isAvatarBusy,
                onChangeAvatar: _changeAvatar,
                onRemoveAvatar: _removeAvatar,
              ),
            ),
          AsyncError(:final error) => FailureView(
              failure: failureFrom(error),
              onRetry: () => ref.invalidate(profileProvider),
            ),
          _ => const LoadingView(),
        },
      ),
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

}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.user,
    required this.isAvatarBusy,
    required this.onChangeAvatar,
    required this.onRemoveAvatar,
  });

  final User user;
  final bool isAvatarBusy;
  final Future<void> Function() onChangeAvatar;
  final Future<void> Function() onRemoveAvatar;

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
