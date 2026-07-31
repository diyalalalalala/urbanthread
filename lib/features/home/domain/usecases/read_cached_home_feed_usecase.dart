import '../../../categories/domain/repositories/categories_repository.dart';
import '../entities/home_feed.dart';
import '../entities/home_product.dart';
import '../repositories/home_repository.dart';

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
