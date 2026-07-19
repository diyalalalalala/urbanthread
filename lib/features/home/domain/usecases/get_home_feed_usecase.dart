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

  /// 12, matching the server default for `/brands/featured` — which is *not*
  /// 10, unlike every product collection route.
  final int brandLimit;
}

/// Builds the whole storefront feed in one pass.
///
/// Six requests, one `Future.wait`. Issuing them serially would make the
/// screen as slow as the sum of six round trips instead of the slowest one,
/// and — more importantly — would let a single stalled endpoint hold back
/// every rail behind it.
///
/// Nothing here throws on a partial failure. Each result is folded into its
/// own [HomeSection], so a dead `/products/best-sellers` costs exactly one
/// rail and the other five render normally. The only way this returns a
/// [FailureResult] is if *every* section failed with nothing cached, which is
/// the one case where there is genuinely nothing to draw.
///
/// It reaches across into [CategoriesRepository] on purpose: the featured
/// strips are the taxonomy's data, and duplicating those two endpoints into a
/// second repository would mean two caches for the same rows, quietly
/// disagreeing.
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
