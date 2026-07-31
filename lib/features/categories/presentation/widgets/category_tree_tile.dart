import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/category.dart';

class CategoryTreeTile extends StatefulWidget {
  const CategoryTreeTile({
    required this.node,
    required this.onOpenCategory,
    super.key,
    this.depth = 0,
    this.initiallyExpanded = false,
  });

  final CategoryNode node;
  final ValueChanged<Category> onOpenCategory;

  final int depth;

  final bool initiallyExpanded;

  @override
  State<CategoryTreeTile> createState() => _CategoryTreeTileState();
}

class _CategoryTreeTileState extends State<CategoryTreeTile>
    with SingleTickerProviderStateMixin {
  late bool _expanded = widget.initiallyExpanded;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDimens.durationMedium,
    value: _expanded ? 1 : 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final node = widget.node;
    final isRoot = widget.depth == 0;

    final indent = AppDimens.space16 * (widget.depth.clamp(0, 3));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => widget.onOpenCategory(node.category),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.space12,
                    ),
                    child: Row(
                      children: [
                        if (isRoot) ...[
                          AppNetworkImage(
                            url: node.category.imageUrl,
                            width: 44,
                            height: 44,
                            borderRadius: AppDimens.borderRadius,
                            placeholderIcon: Icons.category_outlined,
                          ),
                          const SizedBox(width: AppDimens.space12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                node.name,
                                style: isRoot
                                    ? context.text.titleMedium
                                    : context.text.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (node.hasChildren) ...[
                                const SizedBox(height: AppDimens.space2),
                                Text(
                                  '${node.children.length} '
                                  '${node.children.length == 1 ? 'SUBCATEGORY' : 'SUBCATEGORIES'}',
                                  style: AppTypography.eyebrow.copyWith(
                                    color: palette.inkSubtle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (node.hasChildren)
                IconButton(
                  onPressed: _toggle,
                  tooltip: _expanded ? 'Collapse' : 'Expand',
                  icon: RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: AppDimens.easeOutExpo,
                      ),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: palette.inkMuted,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: palette.inkSubtle,
                ),
            ],
          ),
        ),
        ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Align(
              alignment: Alignment.topCenter,
              heightFactor: _controller.value,
              child: child,
            ),
            child: _expanded || _controller.value > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final child in node.children)
                        CategoryTreeTile(
                          node: child,
                          depth: widget.depth + 1,
                          onOpenCategory: widget.onOpenCategory,
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        if (isRoot) Divider(height: 1, color: palette.line),
      ],
    );
  }
}
