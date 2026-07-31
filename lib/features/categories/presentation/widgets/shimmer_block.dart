import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

class ShimmerBlock extends StatefulWidget {
  const ShimmerBlock({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius = AppDimens.borderRadiusSm,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<ShimmerBlock>
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
          borderRadius: widget.borderRadius,
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
