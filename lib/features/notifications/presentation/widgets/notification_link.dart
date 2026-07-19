import '../../../../core/router/app_routes.dart';

/// Translates a notification's `link` into an in-app route.
///
/// `link` is a **web** path the backend writes for the browser client
/// (`/orders/UT-20260718-0042`). `AppRoutes` mirrors those URLs deliberately,
/// so most links map across unchanged — but the set is open-ended and grows
/// server-side, so anything unrecognised resolves to null and the row is
/// rendered as non-navigable rather than pushing a route that does not exist.
///
/// Lives in presentation, not domain: the domain layer may not import the
/// router.
abstract final class NotificationLink {
  const NotificationLink._();

  /// Static paths that map one-to-one.
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

  /// The app path to navigate to, or null when the link is not something this
  /// app can open.
  static String? resolve(String link) {
    final path = link.trim();
    if (path.isEmpty || !path.startsWith('/')) return null;

    // Drop any query or fragment the web client may have appended.
    final clean = path.split('?').first.split('#').first;
    if (_exact.contains(clean)) return clean;

    final segments =
        clean.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.length != 2) return null;

    final [prefix, value] = segments;
    return switch (prefix) {
      // The order routes take whatever the web URL carries — an order
      // *number*, not an ObjectId. That is why the API also exposes
      // `/orders/number/:orderNumber`.
      'orders' => AppRoutes.orderDetailPath(value),
      // Product detail is slug-only; there is no `/products/:id` route to
      // fall back to if this ever carried an id.
      'products' => AppRoutes.productDetailPath(value),
      'category' => AppRoutes.categoryProductsPath(value),
      'brand' => AppRoutes.brandProductsPath(value),
      _ => null,
    };
  }
}
