abstract final class ApiEndpoints {
  const ApiEndpoints._();

  static const register = '/auth/register';
  static const login = '/auth/login';
  static const logout = '/auth/logout';
  static const logoutAll = '/auth/logout-all';
  static const me = '/auth/me';
  static const forgotPassword = '/auth/forgot-password';
  static const changePassword = '/auth/change-password';

  static String resetPassword(String token) => '/auth/reset-password/$token';

  static const profile = '/users/me';
  static const avatar = '/users/me/avatar';
  static const recentlyViewed = '/users/me/recently-viewed';

  static const addresses = '/addresses';

  static String address(String id) => '/addresses/$id';
  static String defaultAddress(String id) => '/addresses/$id/default';

  static const products = '/products';
  static const productSearch = '/products/search';
  static const productFilters = '/products/filters';
  static const featuredProducts = '/products/featured';
  static const trendingProducts = '/products/trending';
  static const bestSellerProducts = '/products/best-sellers';
  static const newArrivalProducts = '/products/new-arrivals';
  static const compareProducts = '/products/compare';

  static String productBySlug(String slug) => '/products/$slug';

  static String relatedProducts(String id) => '/products/$id/related';
  static String frequentlyBoughtTogether(String id) =>
      '/products/$id/frequently-bought-together';

  static const categories = '/categories';
  static const categoryTree = '/categories/tree';

  static String category(String slugOrId) => '/categories/$slugOrId';

  static const brands = '/brands';
  static const featuredBrands = '/brands/featured';

  static String brand(String slugOrId) => '/brands/$slugOrId';

  static const cart = '/cart';
  static const cartSummary = '/cart/summary';
  static const cartValidate = '/cart/validate';
  static const cartItems = '/cart/items';
  static const cartCoupon = '/cart/coupon';

  static String cartItem(String itemId) => '/cart/items/$itemId';
  static String saveForLater(String itemId) =>
      '/cart/items/$itemId/save-for-later';
  static String moveToCart(String itemId) => '/cart/items/$itemId/move-to-cart';

  static const wishlist = '/wishlist';

  static String wishlistItem(String productId) => '/wishlist/$productId';
  static String wishlistCheck(String productId) =>
      '/wishlist/$productId/check';
  static String wishlistMoveToCart(String productId) =>
      '/wishlist/$productId/move-to-cart';

  static const availableCoupons = '/coupons/available';
  static const validateCoupon = '/coupons/validate';

  static const orders = '/orders';
  static const myOrders = '/orders/my-orders';

  static String order(String id) => '/orders/$id';
  static String orderByNumber(String orderNumber) =>
      '/orders/number/$orderNumber';
  static String trackOrder(String id) => '/orders/$id/track';
  static String cancelOrder(String id) => '/orders/$id/cancel';
  static String returnOrder(String id) => '/orders/$id/return';
  static String orderInvoice(String id) => '/orders/$id/invoice';

  static const reviews = '/reviews';
  static const myReviews = '/reviews/my-reviews';
  static const reviewableProducts = '/reviews/reviewable';

  static String productReviews(String productId) =>
      '/reviews/product/$productId';
  static String productReviewStats(String productId) =>
      '/reviews/product/$productId/stats';
  static String review(String id) => '/reviews/$id';
  static String reviewHelpful(String id) => '/reviews/$id/helpful';

  static const notifications = '/notifications';
  static const unreadNotificationCount = '/notifications/unread-count';
  static const readAllNotifications = '/notifications/read-all';
  static const deleteReadNotifications = '/notifications/read';

  static String notification(String id) => '/notifications/$id';
  static String readNotification(String id) => '/notifications/$id/read';
}
