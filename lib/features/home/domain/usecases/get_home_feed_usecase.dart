import 'dart:async';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../categories/domain/entities/brand.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/repositories/categories_repository.dart';
import '../entities/home_feed.dart';
import '../entities/home_product.dart';
import '../repositories/home_repository.dart';

class HomeFeedParams {
  const HomeFeedParams({
    this.productLimit = 10,
    this.categoryLimit = 12,
    this.brandLimit = 12,
  });

  final int productLimit;
  final int categoryLimit;

  final int brandLimit;
}

class GetHomeFeedUseCase extends UseCase<HomeFeed, HomeFeedParams> {
  const GetHomeFeedUseCase({
    required HomeRepository home,
    required CategoriesRepository categories,
  })  : _home = home,
        _categories = categories;

  final HomeRepository _home;
  final CategoriesRepository _categories;

  @override
  Future<Result<HomeFeed>> call(HomeFeedParams params) async {
    final (
      newArrivals,
      trending,
      featured,
      bestSellers,
      categories,
      brands,
    ) = await (
      _home.getCollection(
        HomeCollection.newArrivals,
        limit: params.productLimit,
      ),
      _home.getCollection(HomeCollection.trending, limit: params.productLimit),
      _home.getCollection(HomeCollection.featured, limit: params.productLimit),
      _home.getCollection(
        HomeCollection.bestSellers,
        limit: params.productLimit,
      ),
      _categories.getFeaturedCategories(limit: params.categoryLimit),
      _categories.getFeaturedBrands(limit: params.brandLimit),
    ).wait;

    final feed = HomeFeed(
      newArrivals: _section(newArrivals),
      trending: _section(trending),
      featured: _section(featured),
      bestSellers: _section(bestSellers),
      featuredCategories: _section<Category>(categories),
      featuredBrands: _section<Brand>(brands),
    );

    final blocking = feed.blockingFailure;
    return blocking == null ? Result.success(feed) : Result.failure(blocking);
  }

  static HomeSection<T> _section<T>(Result<List<T>> result) => switch (result) {
        Success(:final value) => HomeSection<T>(items: value),
        FailureResult(:final failure) => HomeSection<T>.failed(failure),
      };
}
