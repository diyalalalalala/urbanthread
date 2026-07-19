import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/category.dart';

/// One branch of the taxonomy, rendered as an expandable row.
///
/// The widget recurses because the data does: `/categories/tree` nests to an
/// unbounded depth, so a fixed parent/child pair of widgets would silently
/// stop rendering at the third tier the moment merchandising adds one.
///
/// Two tap targets on purpose. The label navigates to the category's product
/// list; the chevron only opens the branch. Collapsing those into one gesture
/// forces a choice between "a parent category is browsable" and "a parent
/// category is expandable", and both are true here.
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

  /// Nesting level, used only for the indent. The data's depth is unbounded,
  /// so the indent is capped rather than multiplied without limit.
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

    // Beyond the third tier the indent stops growing; deeper branches are
    // rare and letting them march off the right edge would be worse than a
    // slightly flatter look.
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
        // Descendants are not built until the branch is first opened. A deep
        // taxonomy would otherwise construct every node on the first frame,
        // most of them never seen. Once built they are kept, so re-opening a
        // branch costs nothing.
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
