import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_network_image.dart';

/// A circular avatar that falls back to the user's initials.
///
/// The API's "no avatar" is an empty `avatar.url` inside an always-present
/// object, already flattened to a null `User.avatarUrl` by the model — so a
/// null here genuinely means "never set one", and initials are the right
/// answer rather than a broken-image icon.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.initials,
    super.key,
    this.imageUrl,
    this.size = 72,
  });

  final String initials;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: palette.accentSubtle,
          shape: BoxShape.circle,
          border: Border.all(color: palette.line),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: context.text.titleMedium?.copyWith(
            color: palette.accent,
            fontSize: size * 0.34,
          ),
        ),
      );
    }

    return ClipOval(
      child: AppNetworkImage(
        url: imageUrl,
        width: size,
        height: size,
        placeholderIcon: Icons.person_outline,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
    );
  }
}
