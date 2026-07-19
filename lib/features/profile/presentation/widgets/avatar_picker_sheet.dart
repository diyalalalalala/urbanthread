import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// Asks where the new avatar should come from and returns a local file path.
///
/// Returns null when the user backs out, denies the camera, or picks nothing.
/// Size and MIME validation deliberately are not done here — the repository
/// owns those rules because they are the *backend's* rules (5 MB, and only
/// JPEG/PNG/WebP/AVIF), and a second copy in the UI would drift.
Future<String?> pickAvatarPath(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pageGutter,
              AppDimens.space20,
              AppDimens.pageGutter,
              AppDimens.space8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Change photo',
                style: sheetContext.text.titleMedium,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from library'),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
          ),
          const SizedBox(height: AppDimens.space8),
        ],
      ),
    ),
  );

  if (source == null) return null;

  // Only the camera is gated. Gallery selection goes through the platform
  // photo picker, which grants access to the single chosen item without any
  // storage permission on modern Android and iOS — asking for one anyway
  // would show a dialog the user can refuse for no reason.
  if (source == ImageSource.camera) {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!context.mounted) return null;
      context.showSnack(
        status.isPermanentlyDenied
            ? 'Enable camera access in Settings to take a photo.'
            : 'Camera access is needed to take a photo.',
        isError: true,
      );
      return null;
    }
  }

  final picked = await ImagePicker().pickImage(
    source: source,
    // Downscaled before upload: a modern phone camera easily clears the
    // backend's 5 MB limit, and an avatar is never displayed above ~200px.
    maxWidth: 1200,
    maxHeight: 1200,
    imageQuality: 85,
  );

  return picked?.path;
}
