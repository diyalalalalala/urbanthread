import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/product_filters.dart';
import '../../domain/entities/product_query.dart';
import '../providers/product_list_notifier.dart';
import '../providers/product_providers.dart';
import '../widgets/product_grid.dart';
import '../widgets/sort_sheet.dart';
import 'product_filter_sheet.dart';

/// The browsable catalogue: an infinite grid with sort and filter entry
/// points.
///
/// Parameterised by its starting query so the same page serves "shop all", a
/// category landing and a brand landing — the only difference between them is
/// one filter, and three near-identical screens would drift apart.
class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({
    super.key,
    this.initialQuery = const ProductQuery(),
    this.title = 'Shop all',
  });

  /// Convenience for the category route.
  ProductListPage.forCategory({
    required String categorySlug,
    Key? key,
    String? title,
  }) : this(
          key: key,
          initialQuery: ProductQuery(category: categorySlug),
          title: title ?? 'Category',
        );

  /// Convenience for the brand route. Brand is multi-valued on the wire even
  /// when only one is applied.
  ProductListPage.forBrand({
    required String brandSlug,
    Key? key,
    String? title,
  }) : this(
          key: key,
          initialQuery: ProductQuery(brands: [brandSlug]),
          title: title ?? 'Brand',
        );

  final ProductQuery initialQuery;
  final String title;

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final _scrollController = ScrollController();

  /// How close to the bottom the next page is requested. Roughly two rows of
  /// tiles, which is enough for the request to land before the user arrives.
  static const _loadMoreThreshold = 600.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      // The notifier is the one that de-duplicates: this fires on every
      // frame of a fling, and guarding here as well would still leak.
      ref.read(productListProvider(widget.initialQuery).notifier).loadMore();
    }
  }

  ProductListNotifier get _notifier =>
      ref.read(productListProvider(widget.initialQuery).notifier);

  Future<void> _openSortSheet(ProductSort current) async {
    final sort = await showSortSheet(context, current: current);
    if (sort != null) await _notifier.setSort(sort);
  }

  Future<void> _openFilterSheet(ProductQuery current) async {
    final ProductFilters facets;
    try {
      // Facets may not have loaded yet. Awaiting the provider's future opens
      // the sheet as soon as they land rather than showing an empty one.
      facets = await ref.read(productFilterFacetsProvider.future);
    } on Failure catch (failure) {
      // The provider rethrows the domain Failure, so it arrives here intact.
      if (!mounted) return;
      context.showSnack(failure.message, isError: true);
      return;
    }

    if (!mounted) return;
    final result = await showProductFilterSheet(
      context,
      facets: facets,
      query: current,
    );
    if (result != null) await _notifier.applyQuery(result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider(widget.initialQuery));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => context.push(AppRoutes.search),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          _Toolbar(
            total: state.total,
            query: state.query,
            isLoading: state.isLoading,
            onSort: () => _openSortSheet(state.query.sort),
            onFilter: () => _openFilterSheet(state.query),
          ),
          Divider(height: 1, color: context.palette.line),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _notifier.refresh,
              child: _body(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(ProductListState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const LoadingView(message: 'Loading products…');
    }

    if (state.failure != null && state.items.isEmpty) {
      return _scrollable(
        FailureView(failure: state.failure!, onRetry: _notifier.retry),
      );
    }

    if (state.items.isEmpty) {
      return _scrollable(
        EmptyView(
          title: 'Nothing here yet',
          message: state.query.hasActiveFilters
              ? 'No products match these filters. Try widening them.'
              : 'This part of the catalogue is empty for now.',
          icon: Icons.checkroom_outlined,
          actionLabel: state.query.hasActiveFilters ? 'Clear filters' : null,
          onAction:
              state.query.hasActiveFilters ? _notifier.clearFilters : null,
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pageGutter,
            AppDimens.space16,
            AppDimens.pageGutter,
            AppDimens.space16,
          ),
          sliver: SliverProductGrid(products: state.items),
        ),
        SliverToBoxAdapter(
          child: _ListFooter(
            isLoadingMore: state.isLoadingMore,
            failure: state.loadMoreFailure,
            hasNextPage: state.hasNextPage,
            itemCount: state.items.length,
            onRetry: _notifier.retryLoadMore,
          ),
        ),
      ],
    );
  }

  /// Wraps a centred state view in a scroll view so pull-to-refresh still
  /// works when there is nothing to scroll.
  Widget _scrollable(Widget child) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      );
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.total,
    required this.query,
    required this.isLoading,
    required this.onSort,
    required this.onFilter,
  });

  final int total;
  final ProductQuery query;
  final bool isLoading;
  final VoidCallback onSort;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final activeCount = query.activeFilterCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pageGutter,
        AppDimens.space8,
        AppDimens.space8,
        AppDimens.space8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isLoading ? '' : '$total ${total == 1 ? 'item' : 'items'}',
              style: AppTypography.eyebrow.copyWith(color: palette.inkSubtle),
            ),
          ),
          TextButton.icon(
            onPressed: onSort,
            icon: const Icon(Icons.swap_vert, size: 18),
            label: Text(query.sort.label.toUpperCase()),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onFilter,
                tooltip: 'Filters',
                icon: const Icon(Icons.tune),
              ),
              if (activeCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.accent,
                      borderRadius: AppDimens.borderRadiusXl,
                    ),
                    child: Text(
                      '$activeCount',
                      style: AppTypography.eyebrow.copyWith(
                        color: palette.accentInk,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The bottom of the grid: a spinner, a retry, or the end of the catalogue.
class _ListFooter extends StatelessWidget {
  const _ListFooter({
    required this.isLoadingMore,
    required this.failure,
    required this.hasNextPage,
    required this.itemCount,
    required this.onRetry,
  });

  final bool isLoadingMore;
  final Failure? failure;
  final bool hasNextPage;
  final int itemCount;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.space24),
        child: LoadingView(),
      );
    }

    if (failure != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space24),
        child: Column(
          children: [
            Text(
              failure!.message,
              style: context.text.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('LOAD MORE'),
            ),
          ],
        ),
      );
    }

    // Only worth announcing the end once there is enough behind it that the
    // shopper actually scrolled.
    if (!hasNextPage && itemCount > 6) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space32),
        child: Center(
          child: Text(
            "THAT'S EVERYTHING",
            style: AppTypography.eyebrow.copyWith(
              color: context.palette.inkSubtle,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: AppDimens.space32);
  }
}
