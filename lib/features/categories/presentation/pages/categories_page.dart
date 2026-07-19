import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/category.dart';
import '../providers/categories_notifier.dart';
import '../providers/categories_state.dart';
import '../widgets/brand_tile.dart';
import '../widgets/category_tree_tile.dart';
import '../widgets/shimmer_block.dart';

/// Browse the catalogue by taxonomy.
///
/// The tree is rendered as expandable sections rather than a two-pane
/// master/detail because the depth is unbounded — a two-pane layout has to
/// pick a level to put in each pane, and this taxonomy does not promise to
/// have exactly two.
///
/// Both destinations are plain paths so this screen owns no routing:
/// [AppRoutes.categoryProductsPath] and [AppRoutes.brandProductsPath] build
/// `/category/<slug>` and `/brand/<slug>`, which the app router resolves to
/// the filtered catalogue.
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCategory(Category category) =>
      context.go(AppRoutes.categoryProductsPath(category.slug));

  void _openBrand(Brand brand) =>
      context.go(AppRoutes.brandProductsPath(brand.slug));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriesProvider);
    final isOffline = !ref.watch(isOnlineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Column(
        children: [
          if (isOffline) const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(categoriesProvider.notifier).refresh(),
              child: _body(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(CategoriesState state) {
    // A first load with an empty cache is the only case that gets a spinner;
    // anything already on disk is painted immediately and refreshed behind.
    if (state.isLoading && !state.hasAnyContent) {
      return const _CategoriesSkeleton();
    }

    final blocking = state.blockingFailure;
    if (blocking != null) {
      // `AlwaysScrollableScrollPhysics` keeps pull-to-refresh reachable on a
      // screen whose content is too short to scroll — without it the only way
      // out of an error state would be to leave and come back.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: context.screenHeight * 0.15),
          FailureView(
            failure: blocking,
            onRetry: () => ref.read(categoriesProvider.notifier).refresh(),
          ),
        ],
      );
    }

    final matches = _matchingCategories(state);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _searchField()),
        if (_query.isNotEmpty)
          _searchResults(matches)
        else ...[
          _treeSection(state),
          _brandsSection(state),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.space40)),
      ],
    );
  }

  /// Flat, case-insensitive match over every category at every depth.
  ///
  /// Searching client-side rather than through `/categories?search=` is a
  /// deliberate trade: the whole taxonomy is already in memory, so filtering
  /// it is instant and keeps working offline, which a request would not.
  List<Category> _matchingCategories(CategoriesState state) {
    if (_query.isEmpty) return const [];
    final needle = _query.toLowerCase();
    return [
      for (final category in state.allCategories)
        if (category.name.toLowerCase().contains(needle)) category,
    ];
  }

  Widget _searchField() => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pageGutter,
          AppDimens.space16,
          AppDimens.pageGutter,
          AppDimens.space8,
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: InputDecoration(
            hintText: 'Search categories',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
      );

  Widget _searchResults(List<Category> matches) {
    if (matches.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: AppDimens.space48),
          child: EmptyView(
            title: 'No categories found',
            message: 'Try a different word, or clear the search to browse '
                'everything.',
            icon: Icons.search_off_outlined,
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: matches.length,
      separatorBuilder: (context, _) =>
          Divider(height: 1, color: context.palette.line),
      itemBuilder: (context, index) {
        final category = matches[index];
        return ListTile(
          title: Text(category.name, style: context.text.bodyLarge),
          subtitle: category.description.isEmpty
              ? null
              : Text(
                  category.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => _openCategory(category),
        );
      },
    );
  }

  Widget _treeSection(CategoriesState state) {
    if (!state.hasTree) {
      return SliverToBoxAdapter(
        child: _SectionFailure(
          label: 'Categories are unavailable right now.',
          failureMessage: state.treeFailure?.message,
        ),
      );
    }

    return SliverList.builder(
      itemCount: state.tree.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.pageGutter),
        child: CategoryTreeTile(
          node: state.tree[index],
          // The first branch opens by default so the screen shows the shape
          // of the taxonomy rather than a wall of closed rows.
          initiallyExpanded: index == 0,
          onOpenCategory: _openCategory,
        ),
      ),
    );
  }

  Widget _brandsSection(CategoriesState state) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pageGutter,
            AppDimens.space32,
            AppDimens.pageGutter,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SHOP BY BRAND',
                style: AppTypography.eyebrow.copyWith(
                  color: context.palette.inkMuted,
                ),
              ),
              const SizedBox(height: AppDimens.space16),
              if (!state.hasBrands)
                _SectionFailure(
                  label: 'Brands are unavailable right now.',
                  failureMessage: state.brandsFailure?.message,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Two columns on a phone, three or four as the width
                    // allows — brand names are short, and a single column
                    // would make the directory a very long scroll.
                    final columns = constraints.maxWidth >= 900
                        ? 4
                        : constraints.maxWidth >= 600
                            ? 3
                            : 2;
                    const gap = AppDimens.space12;
                    final tileWidth =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final brand in state.brands)
                          BrandTile(
                            brand: brand,
                            width: tileWidth,
                            onTap: () => _openBrand(brand),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      );
}

/// A quiet, in-place message for one section that failed while the rest of
/// the screen is fine. Not a [FailureView]: this must not look like the whole
/// screen is broken when only a strip is.
class _SectionFailure extends StatelessWidget {
  const _SectionFailure({required this.label, this.failureMessage});

  final String label;
  final String? failureMessage;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          border: Border.all(color: context.palette.line),
          borderRadius: AppDimens.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.text.bodyMedium),
            if (failureMessage != null) ...[
              const SizedBox(height: AppDimens.space4),
              Text(
                failureMessage!,
                style: context.text.bodySmall?.copyWith(
                  color: context.palette.inkSubtle,
                ),
              ),
            ],
          ],
        ),
      );
}

/// Cold-start placeholder, using the same shimmer treatment as the one
/// inside `AppNetworkImage` so a loading screen and a loading image read as
/// one system rather than two.
class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.pageGutter,
          vertical: AppDimens.space16,
        ),
        children: [
          for (var index = 0; index < 8; index++) ...[
            Row(
              children: [
                const ShimmerBlock(width: 44, height: 44),
                const SizedBox(width: AppDimens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBlock(
                        width: 120 + (index.isEven ? 40 : 0),
                        height: 12,
                      ),
                      const SizedBox(height: AppDimens.space8),
                      const ShimmerBlock(width: 72, height: 9),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space24),
          ],
        ],
      );
}
