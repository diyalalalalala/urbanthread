import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../../categories/domain/entities/brand.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/home_product.dart';
import '../providers/home_feed_notifier.dart';
import '../providers/home_feed_state.dart';
import '../widgets/featured_brands_strip.dart';
import '../widgets/featured_categories_strip.dart';
import '../widgets/home_hero.dart';
import '../widgets/product_rail.dart';

/// The storefront landing screen.
///
/// Composed entirely from [homeFeedProvider], which loads all six sections
/// concurrently and hands back a feed where each section carries its own
/// outcome. That is what lets this build method stay declarative: every
/// section decides for itself whether to render, retry or disappear, so there
/// is no per-section branching here.
///
/// Navigation is by path string only — this screen owns no routing. The paths
/// come from [AppRoutes], and go_router resolves them.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeFeedProvider);
    final isOffline = !ref.watch(isOnlineProvider);
    final userName = ref.watch(currentUserProvider)?.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('URBANTHREAD'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.search),
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
          IconButton(
            onPressed: () => context.go(AppRoutes.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'Bag',
          ),
        ],
      ),
      body: Column(
        children: [
          // Informs rather than interrupts: everything below is cached and
          // fully browsable without a connection.
          if (isOffline) const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(homeFeedProvider.notifier).refresh(),
              child: _body(context, ref, state, userName),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    HomeFeedState state,
    String? userName,
  ) {
    final blocking = state.blockingFailure;

    // Only a genuinely cold start with a dead network reaches here: any cached
    // content at all suppresses `blockingFailure`, which is the offline-first
    // requirement expressed as a single condition.
    if (blocking != null && !state.hasContent) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: context.screenHeight * 0.2),
          FailureView(
            failure: blocking,
            onRetry: () => ref.read(homeFeedProvider.notifier).refresh(),
          ),
        ],
      );
    }

    final feed = state.feed;
    final showSkeletons = state.isLoading && !state.hasContent;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppDimens.space48),
      children: [
        HomeHero(
          userName: userName,
          onShopAll: () => context.go(AppRoutes.products),
        ),
        FeaturedCategoriesStrip(
          section: feed.featuredCategories,
          isLoading: showSkeletons,
          onSeeAll: () => context.go(AppRoutes.categories),
          onOpenCategory: (category) => _openCategory(context, category),
        ),
        // The rails are driven off the feed's own ordering rather than a list
        // literal here, so adding a collection is a one-line change in the
        // entity instead of an edit in two files that must agree.
        for (final entry in feed.rails.entries)
          ProductRail(
            collection: entry.key,
            section: entry.value,
            isLoading: showSkeletons,
            onSeeAll: () => context.go(entry.key.seeAllPath),
            onRetry: () =>
                ref.read(homeFeedProvider.notifier).refreshRail(entry.key),
            onOpenProduct: (product) => _openProduct(context, product),
          ),
        FeaturedBrandsStrip(
          section: feed.featuredBrands,
          isLoading: showSkeletons,
          onSeeAll: () => context.go(AppRoutes.categories),
          onOpenBrand: (brand) => _openBrand(context, brand),
        ),
      ],
    );
  }

  /// Product detail is slug-only — there is no `/products/:id` route on the
  /// backend, which is why every card carries its slug.
  void _openProduct(BuildContext context, HomeProduct product) =>
      context.go(AppRoutes.productDetailPath(product.slug));

  void _openCategory(BuildContext context, Category category) =>
      context.go(AppRoutes.categoryProductsPath(category.slug));

  void _openBrand(BuildContext context, Brand brand) =>
      context.go(AppRoutes.brandProductsPath(brand.slug));
}
