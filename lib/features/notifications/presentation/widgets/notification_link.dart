import '../../../../core/router/app_routes.dart';

abstract final class NotificationLink {
  const NotificationLink._();

  static const _exact = {
    AppRoutes.orders,
    AppRoutes.wishlist,
    AppRoutes.cart,
    AppRoutes.profile,
    AppRoutes.notifications,
    AppRoutes.settings,
    AppRoutes.addresses,
    AppRoutes.myReviews,
    AppRoutes.recentlyViewed,
    AppRoutes.categories,
    AppRoutes.search,
    AppRoutes.products,
  };

  static String? resolve(String link) {
    final path = link.trim();
    if (path.isEmpty || !path.startsWith('/')) return null;

    final clean = path.split('?').first.split('#').first;
    if (_exact.contains(clean)) return clean;

    final segments =
        clean.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.length != 2) return null;

    final [prefix, value] = segments;
    return switch (prefix) {
      'orders' => AppRoutes.orderDetailPath(value),
      'products' => AppRoutes.productDetailPath(value),
      'category' => AppRoutes.categoryProductsPath(value),
      'brand' => AppRoutes.brandProductsPath(value),
      _ => null,
    };
  }
}
