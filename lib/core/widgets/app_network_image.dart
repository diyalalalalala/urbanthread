import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';
import '../utils/media_url.dart';

/// Every remote image in the app goes through here.
///
/// Centralising it buys three things a bare [CachedNetworkImage] would not:
/// the URL is re-based so `localhost` links from the backend resolve on a
/// device, "no image" (which the API spells as an empty string) renders a
/// placeholder instead of an error, and the on-disk cache makes the catalogue
/// browsable offline — which is the whole point of the offline-first
/// requirement.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderIcon = Icons.checkroom_outlined,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final resolved = MediaUrl.resolve(url);
    final radius = borderRadius ?? BorderRadius.zero;

    if (resolved == null) {
      return ClipRRect(
        borderRadius: radius,
        child: _Placeholder(
          width: width,
          height: height,
          icon: placeholderIcon,
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: resolved,
        fit: fit,
        width: width,
        height: height,
        fadeInDuration: AppDimens.durationFast,
        // No fade on the way out: when an image is already in the memory
        // cache it resolves synchronously, and cross-fading from a
        // placeholder that was never visible reads as a flicker.
        fadeOutDuration: Duration.zero,
        placeholder: (context, _) => _Shimmer(width: width, height: height),
        errorWidget: (context, _, __) => _Placeholder(
          width: width,
          height: height,
          icon: placeholderIcon,
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.width, this.height, required this.icon});

  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        color: context.palette.surfaceSunken,
        alignment: Alignment.center,
        child: Icon(icon, color: context.palette.inkSubtle, size: 28),
      );
}

/// The web client's `shimmer 1.6s` loading treatment.
class _Shimmer extends StatefulWidget {
  const _Shimmer({this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              palette.surfaceSunken,
              palette.surfaceRaised,
              palette.surfaceSunken,
            ],
            stops: const [0, 0.5, 1],
            begin: Alignment(-1 - 2 * _controller.value, 0),
            end: Alignment(1 - 2 * _controller.value, 0),
          ),
        ),
      ),
    );
  }
}
