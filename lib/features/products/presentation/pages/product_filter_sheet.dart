import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product_filters.dart';
import '../../domain/entities/product_query.dart';

/// Opens the filter sheet over [query], resolving to the edited query or to
/// null if it was dismissed without applying.
Future<ProductQuery?> showProductFilterSheet(
  BuildContext context, {
  required ProductFilters facets,
  required ProductQuery query,
}) =>
    showModalBottomSheet<ProductQuery>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLg),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      builder: (context) => ProductFilterSheet(facets: facets, query: query),
    );

/// Every facet `/products/filters` offers, as one editable draft.
///
/// The sheet edits a *copy* of the query and only returns it on Apply, so
/// backing out leaves the grid exactly as it was. Refetching on every chip
/// tap would be the alternative, and on a mobile connection it makes the
/// sheet feel broken.
///
/// Facet counts come from the endpoint and are shown next to each value —
/// they are what stop a shopper stacking filters into an empty result set.
class ProductFilterSheet extends StatefulWidget {
  const ProductFilterSheet({
    required this.facets,
    required this.query,
    super.key,
  });

  final ProductFilters facets;
  final ProductQuery query;

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late ProductQuery _draft = widget.query;
  late RangeValues _priceRange = _initialPriceRange();

  PriceRange get _bounds => widget.facets.priceRange;

  RangeValues _initialPriceRange() {
    final range = widget.facets.priceRange;
    final start = (widget.query.minPrice ?? range.min).clamp(
      range.min,
      range.max,
    );
    final end = (widget.query.maxPrice ?? range.max).clamp(
      range.min,
      range.max,
    );
    // A query whose bounds arrived inverted (hand-built deep link) would make
    // RangeSlider assert, so they are ordered here rather than trusted.
    return RangeValues(start <= end ? start : end, start <= end ? end : start);
  }

  /// Adds or removes [value] from a multi-value facet.
  void _toggle(
    List<String> current,
    String value,
    void Function(List<String> next) apply,
  ) {
    final next = [...current];
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    apply(next);
  }

  void _apply() {
    var result = _draft;

    // Only send price bounds that actually narrow the catalogue. Sending the
    // full range would filter on `effectivePrice` for no reason and would
    // wrongly light up the "filters active" badge.
    final touchedMin = _priceRange.start > _bounds.min;
    final touchedMax = _priceRange.end < _bounds.max;
    result = _bounds.isCollapsed || (!touchedMin && !touchedMax)
        ? result.copyWith(clearPriceRange: true)
        : result.copyWith(
            minPrice: touchedMin ? _priceRange.start : null,
            maxPrice: touchedMax ? _priceRange.end : null,
          );

    Navigator.of(context).pop(result.reset());
  }

  void _clear() {
    setState(() {
      _draft = widget.query.clearFilters();
      _priceRange = RangeValues(_bounds.min, _bounds.max);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final facets = widget.facets;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            activeCount: _draft.activeFilterCount,
            onClear: _clear,
          ),
          Divider(height: 1, color: palette.line),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.pageGutter,
                vertical: AppDimens.space20,
              ),
              children: [
                if (!_bounds.isCollapsed) ...[
                  _SectionHeader(
                    label: 'Price',
                    trailing:
                        '${Formatters.price(_priceRange.start)} – '
                        '${Formatters.price(_priceRange.end)}',
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: _bounds.min,
                    max: _bounds.max,
                    // One division per rupee would be unusable on a wide
                    // catalogue; 40 steps keeps the thumb snappy and the
                    // resulting bound is still exact enough to filter on.
                    divisions: 40,
                    labels: RangeLabels(
                      Formatters.price(_priceRange.start),
                      Formatters.price(_priceRange.end),
                    ),
                    onChanged: (values) =>
                        setState(() => _priceRange = values),
                  ),
                  const SizedBox(height: AppDimens.space16),
                ],

                if (facets.categories.isNotEmpty) ...[
                  const _SectionHeader(label: 'Category'),
                  Wrap(
                    spacing: AppDimens.space8,
                    runSpacing: AppDimens.space8,
                    children: [
                      // Single-select: the `category` parameter takes one slug
                      // or id, unlike the other facets.
                      for (final category in facets.categories)
                        _FilterChip(
                          label: category.name,
                          count: category.count,
                          isSelected: _draft.category == category.slug,
                          onTap: () => setState(() {
                            _draft = _draft.category == category.slug
                                ? _draft.copyWith(clearCategory: true)
                                : _draft.copyWith(category: category.slug);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space24),
                ],

                if (facets.brands.isNotEmpty) ...[
                  const _SectionHeader(label: 'Brand'),
                  Wrap(
                    spacing: AppDimens.space8,
                    runSpacing: AppDimens.space8,
                    children: [
                      for (final brand in facets.brands)
                        _FilterChip(
                          label: brand.name,
                          count: brand.count,
                          isSelected: _draft.brands.contains(brand.slug),
                          onTap: () => setState(
                            () => _toggle(
                              _draft.brands,
                              brand.slug,
                              (next) => _draft = _draft.copyWith(brands: next),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space24),
                ],

                if (facets.sizes.isNotEmpty) ...[
                  // `size` and `color` together are matched with `$elemMatch`,
                  // so a single variant must satisfy both — picking "M" and
                  // "Red" finds red mediums, not products that stock a medium
                  // in some colour and a red in some size.
                  const _SectionHeader(label: 'Size'),
                  Wrap(
                    spacing: AppDimens.space8,
                    runSpacing: AppDimens.space8,
                    children: [
                      for (final size in facets.sizes)
                        _FilterChip(
                          label: size.name,
                          count: size.count,
                          isSelected: _draft.sizes.contains(size.name),
                          onTap: () => setState(
                            () => _toggle(
                              _draft.sizes,
                              size.name,
                              (next) => _draft = _draft.copyWith(sizes: next),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space24),
                ],

                if (facets.colors.isNotEmpty) ...[
                  const _SectionHeader(label: 'Colour'),
                  Wrap(
                    spacing: AppDimens.space8,
                    runSpacing: AppDimens.space8,
                    children: [
                      for (final color in facets.colors)
                        _FilterChip(
                          label: color.name,
                          count: color.count,
                          swatch:
                              color.argb == null ? null : Color(color.argb!),
                          isSelected: _draft.colors.contains(color.name),
                          onTap: () => setState(
                            () => _toggle(
                              _draft.colors,
                              color.name,
                              (next) => _draft = _draft.copyWith(colors: next),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space24),
                ],

                const _SectionHeader(label: 'Rating'),
                Wrap(
                  spacing: AppDimens.space8,
                  runSpacing: AppDimens.space8,
                  children: [
                    for (final threshold in [4.0, 3.0, 2.0])
                      _FilterChip(
                        label: '${threshold.toStringAsFixed(0)}★ & up',
                        isSelected: _draft.minRating == threshold,
                        onTap: () => setState(() {
                          _draft = _draft.minRating == threshold
                              ? _draft.copyWith(clearMinRating: true)
                              : _draft.copyWith(minRating: threshold);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.space24),

                if (facets.tags.isNotEmpty) ...[
                  const _SectionHeader(label: 'Tags'),
                  Wrap(
                    spacing: AppDimens.space8,
                    runSpacing: AppDimens.space8,
                    children: [
                      for (final tag in facets.tags)
                        _FilterChip(
                          label: tag.name,
                          count: tag.count,
                          isSelected: _draft.tags.contains(tag.name),
                          onTap: () => setState(
                            () => _toggle(
                              _draft.tags,
                              tag.name,
                              (next) => _draft = _draft.copyWith(tags: next),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space24),
                ],

                const _SectionHeader(label: 'Availability'),
                _SwitchRow(
                  label: 'In stock only',
                  value: _draft.inStock ?? false,
                  onChanged: (value) => setState(() {
                    _draft = value
                        ? _draft.copyWith(inStock: true)
                        : _draft.copyWith(clearInStock: true);
                  }),
                ),
                _SwitchRow(
                  label: 'On sale',
                  value: _draft.hasDiscount ?? false,
                  onChanged: (value) => setState(() {
                    _draft = value
                        ? _draft.copyWith(hasDiscount: true)
                        : _draft.copyWith(
                            clearHasDiscount: true,
                            clearMinDiscount: true,
                          );
                  }),
                ),
                _SwitchRow(
                  label: 'New arrivals',
                  value: _draft.isNewArrival ?? false,
                  // Cleared rather than set to false: `isNewArrival=false`
                  // is a valid filter that would hide every new arrival,
                  // which is not what switching the toggle off means.
                  onChanged: (value) => setState(() {
                    _draft = value
                        ? _draft.copyWith(isNewArrival: true)
                        : _draft.copyWith(clearIsNewArrival: true);
                  }),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: palette.line),
          Padding(
            padding: const EdgeInsets.all(AppDimens.pageGutter),
            child: SizedBox(
              width: double.infinity,
              height: AppDimens.controlHeight,
              child: FilledButton(
                onPressed: _apply,
                child: const Text('APPLY FILTERS'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.activeCount, required this.onClear});

  final int activeCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pageGutter,
          AppDimens.space16,
          AppDimens.space8,
          AppDimens.space12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text('Filters', style: context.text.headlineSmall),
            ),
            if (activeCount > 0)
              TextButton(
                onPressed: onClear,
                child: const Text('CLEAR ALL'),
              ),
            IconButton(
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Icons.close),
              tooltip: 'Close',
            ),
          ],
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.trailing});

  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.space12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: AppTypography.eyebrow.copyWith(
                  color: context.palette.inkSubtle,
                ),
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: context.text.labelMedium),
          ],
        ),
      );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
    this.swatch,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;
  final Color? swatch;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space12,
          vertical: AppDimens.space8,
        ),
        constraints: const BoxConstraints(minHeight: AppDimens.controlHeightSm),
        decoration: BoxDecoration(
          color: isSelected ? palette.accentSubtle : palette.surface,
          borderRadius: AppDimens.borderRadius,
          border: Border.all(
            color: isSelected ? palette.accent : palette.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (swatch != null) ...[
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: swatch,
                  border: Border.all(color: palette.line),
                ),
              ),
              const SizedBox(width: AppDimens.space8),
            ],
            Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: isSelected ? palette.accent : palette.ink,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: AppDimens.space4),
              Text(
                '($count)',
                style: context.text.labelMedium?.copyWith(
                  color: palette.inkSubtle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: context.text.bodyMedium),
        value: value,
        onChanged: onChanged,
      );
}
