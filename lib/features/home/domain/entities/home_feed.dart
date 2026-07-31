import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../categories/domain/entities/brand.dart';
import '../../../categories/domain/entities/category.dart';
import 'home_product.dart';

class HomeSection<T> extends Equatable {
  const HomeSection({this.items = const [], this.failure});

  const HomeSection.empty() : items = const [], failure = null;

  const HomeSection.failed(Failure this.failure) : items = const [];

  final List<T> items;

  final Failure? failure;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool get isHidden => items.isEmpty;

  HomeSection<T> copyWith({List<T>? items, Failure? failure, bool clearFailure = false}) =>
      HomeSection<T>(
        items: items ?? this.items,
        failure: clearFailure ? null : (failure ?? this.failure),
      );

  @override
  List<Object?> get props => [items, failure];
}

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

  bool get hasContent =>
      newArrivals.isNotEmpty ||
      trending.isNotEmpty ||
      featured.isNotEmpty ||
      bestSellers.isNotEmpty ||
      featuredCategories.isNotEmpty ||
      featuredBrands.isNotEmpty;

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
