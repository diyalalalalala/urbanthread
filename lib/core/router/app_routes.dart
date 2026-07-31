abstract final class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password/:token';

  static const home = '/';
  static const categories = '/categories';
  static const search = '/search';
  static const wishlist = '/wishlist';
  static const profile = '/profile';

  static const products = '/products';
  static const productDetail = '/products/:slug';
  static const categoryProducts = '/category/:slug';
  static const brandProducts = '/brand/:slug';

  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderConfirmation = '/order-confirmation/:id';

  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  static const orderTracking = '/orders/:id/track';

  static const addresses = '/profile/addresses';
  static const editProfile = '/profile/edit';
  static const changePassword = '/profile/password';
  static const myReviews = '/profile/reviews';
  static const recentlyViewed = '/profile/recently-viewed';
  static const notifications = '/notifications';
  static const settings = '/settings';

  static String productDetailPath(String slug) => '/products/$slug';
  static String categoryProductsPath(String slug) => '/category/$slug';
  static String brandProductsPath(String slug) => '/brand/$slug';
  static String orderDetailPath(String id) => '/orders/$id';
  static String orderTrackingPath(String id) => '/orders/$id/track';
  static String orderConfirmationPath(String id) => '/order-confirmation/$id';
  static String resetPasswordPath(String token) => '/reset-password/$token';
}

abstract final class AppRouteNames {
  const AppRouteNames._();

  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgotPassword';
  static const resetPassword = 'resetPassword';
  static const home = 'home';
  static const categories = 'categories';
  static const search = 'search';
  static const wishlist = 'wishlist';
  static const profile = 'profile';
  static const products = 'products';
  static const productDetail = 'productDetail';
  static const categoryProducts = 'categoryProducts';
  static const brandProducts = 'brandProducts';
  static const cart = 'cart';
  static const checkout = 'checkout';
  static const orderConfirmation = 'orderConfirmation';
  static const orders = 'orders';
  static const orderDetail = 'orderDetail';
  static const orderTracking = 'orderTracking';
  static const addresses = 'addresses';
  static const editProfile = 'editProfile';
  static const changePassword = 'changePassword';
  static const myReviews = 'myReviews';
  static const recentlyViewed = 'recentlyViewed';
  static const notifications = 'notifications';
  static const settings = 'settings';
}
