import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../categories/domain/entities/brand.dart';
import '../../../categories/domain/entities/category.dart';
import 'home_product.dart';

/// One strip of the home screen, with its own outcome.
///
/// The failure travels *with* the data rather than beside the whole feed
/// because the home screen is six independent requests stitched together.
/// A single screen-level error would mean a dead `/products/best-sellers`
/// blanks four working rails — which is exactly the failure mode this type
/// exists to prevent.
class HomeSection<T> extends Equatable {
  const HomeSection({this.items = const [], this.failure});

  const HomeSection.empty() : items = const [], failure = null;

  const HomeSection.failed(Failure this.failure) : items = const [];

  final List<T> items;

  /// Non-null when this strip could not be loaded. It may be non-null *and*
  /// [items] non-empty: a refresh that failed over content that is already
  /// on screen, where the right behaviour is to keep showing the content.
  final Failure? failure;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  /// Whether the strip should be hidden entirely. A rail with nothing to show
  /// is removed rather than rendered as an empty box with a heading.
  bool get isHidden => items.isEmpty;

  HomeSection<T> copyWith({List<T>? items, Failure? failure, bool clearFailure = false}) =>
      HomeSection<T>(
        items: items ?? this.items,
        failure: clearFailure ? null : (failure ?? this.failure),
      );

  @override
  List<Object?> get props => [items, failure];
}

/// Everything the storefront landing screen renders.
///
/// Assembled from six endpoints in parallel. Any subset may be empty; the
/// screen composes whatever arrived.
class HomeFeed extends Equatable {
  const HomeFeed({
    this.newArrivals = const HomeSection<HomeProduct>.empty(),
    this.trending = const HomeSection<HomeProduct>.empty(),
    this.featured = const HomeSection<HomeProduct>.empty(),
    this.bestSellers = const HomeSection<HomeProduct>.empty(),
    this.featuredCategories = const HomeSection<Category>.empty(),
    this.featuredBrands = const HomeSection<Brand>.empty(),
  });

  const HomeFeed.empty()
      : newArrivals = const HomeSection<HomeProduct>.empty(),
        trending = const HomeSection<HomeProduct>.empty(),
        featured = const HomeSection<HomeProduct>.empty(),
        bestSellers = const HomeSection<HomeProduct>.empty(),
        featuredCategories = const HomeSection<Category>.empty(),
        featuredBrands = const HomeSection<Brand>.empty();

  final HomeSection<HomeProduct> newArrivals;
  final HomeSection<HomeProduct> trending;
  final HomeSection<HomeProduct> featured;
  final HomeSection<HomeProduct> bestSellers;
  final HomeSection<Category> featuredCategories;
  final HomeSection<Brand> featuredBrands;

  /// The product rails in the order they appear on screen.
  ///
  /// New arrivals lead: it is the rail whose contents change most often, so
  /// it is the one that rewards a returning visitor for coming back.
  Map<HomeCollection, HomeSection<HomeProduct>> get rails => {
        HomeCollection.newArrivals: newArrivals,
        HomeCollection.trending: trending,
        HomeCollection.featured: featured,
        HomeCollection.bestSellers: bestSellers,
      };

  HomeSection<HomeProduct> rail(HomeCollection collection) =>
      switch (collection) {
        HomeCollection.newArrivals => newArrivals,
        HomeCollection.trending => trending,
        HomeCollection.featured => featured,
        HomeCollection.bestSellers => bestSellers,
      };

  /// True when there is at least one thing worth drawing.
  bool get hasContent =>
      newArrivals.isNotEmpty ||
      trending.isNotEmpty ||
      featured.isNotEmpty ||
      bestSellers.isNotEmpty ||
      featuredCategories.isNotEmpty ||
      featuredBrands.isNotEmpty;

  /// A failure worth showing full-screen, or null.
  ///
  /// Only meaningful when nothing at all loaded: as long as one rail has
  /// content, the screen is useful and an error page would be a regression.
  Failure? get blockingFailure {
    if (hasContent) return null;
    for (final section in [
      newArrivals,
      trending,
      featured,
      bestSellers,
      featuredCategories,
      featuredBrands,
    ]) {
      if (section.failure != null) return section.failure;
    }
    return null;
  }

  HomeFeed copyWith({
    HomeSection<HomeProduct>? newArrivals,
    HomeSection<HomeProduct>? trending,
    HomeSection<HomeProduct>? featured,
    HomeSection<HomeProduct>? bestSellers,
    HomeSection<Category>? featuredCategories,
    HomeSection<Brand>? featuredBrands,
  }) =>
      HomeFeed(
        newArrivals: newArrivals ?? this.newArrivals,
        trending: trending ?? this.trending,
        featured: featured ?? this.featured,
        bestSellers: bestSellers ?? this.bestSellers,
        featuredCategories: featuredCategories ?? this.featuredCategories,
        featuredBrands: featuredBrands ?? this.featuredBrands,
      );

  /// Overlays [next] on this feed, keeping the current contents of any
  /// section that came back empty **and** failed.
  ///
  /// This is what makes a refresh non-destructive: a rail whose request died
  /// keeps whatever it was already showing, so pulling to refresh on a train
  /// cannot empty a screen that was working a moment ago.
  HomeFeed mergeWith(HomeFeed next) => HomeFeed(
        newArrivals: _merge(newArrivals, next.newArrivals),
        trending: _merge(trending, next.trending),
        featured: _merge(featured, next.featured),
        bestSellers: _merge(bestSellers, next.bestSellers),
        featuredCategories: _merge(featuredCategories, next.featuredCategories),
        featuredBrands: _merge(featuredBrands, next.featuredBrands),
      );

  static HomeSection<T> _merge<T>(HomeSection<T> current, HomeSection<T> next) {
    if (next.isNotEmpty) return next;
    if (next.failure != null && current.isNotEmpty) {
      return current.copyWith(failure: next.failure);
    }
    return next;
  }

  @override
  List<Object?> get props => [
        newArrivals,
        trending,
        featured,
        bestSellers,
        featuredCategories,
        featuredBrands,
      ];
}
