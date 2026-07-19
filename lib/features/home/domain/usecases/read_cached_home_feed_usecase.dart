import '../../../categories/domain/repositories/categories_repository.dart';
import '../entities/home_feed.dart';
import '../entities/home_product.dart';
import '../repositories/home_repository.dart';

/// The last known storefront, assembled entirely from disk.
///
/// Deliberately **not** a `UseCase`: that contract is
/// `Future<Result<T>>`, and this cannot fail and does not await. Hive reads
/// are synchronous, so forcing this through the async shape would push the
/// first paint a frame later and add an error branch that can never be taken
/// — all to satisfy a signature. It lives in `usecases/` because that is what
/// it is; only its return type differs.
///
/// This is what makes the offline requirement literal: with no connection at
/// all, the home screen still opens fully populated on the first frame.
class ReadCachedHomeFeedUseCase {
  const ReadCachedHomeFeedUseCase({
    required HomeRepository home,
    required CategoriesRepository categories,
  })  : _home = home,
        _categories = categories;

  final HomeRepository _home;
  final CategoriesRepository _categories;

  HomeFeed call() => HomeFeed(
        newArrivals: HomeSection(
          items: _home.cachedCollection(HomeCollection.newArrivals),
        ),
        trending: HomeSection(
          items: _home.cachedCollection(HomeCollection.trending),
        ),
        featured: HomeSection(
          items: _home.cachedCollection(HomeCollection.featured),
        ),
        bestSellers: HomeSection(
          items: _home.cachedCollection(HomeCollection.bestSellers),
        ),
        featuredCategories:
            HomeSection(items: _categories.cachedFeaturedCategories()),
        featuredBrands: HomeSection(items: _categories.cachedFeaturedBrands()),
      );
}
