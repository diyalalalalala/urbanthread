import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/reset_password_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/providers/auth_notifier.dart';
import '../../features/authentication/presentation/providers/auth_state.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/providers/cart_notifier.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/checkout/presentation/pages/order_success_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/order_tracking_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/domain/entities/product_query.dart';
import '../../features/products/presentation/providers/product_detail_notifier.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/my_reviews_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/recently_viewed_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/wishlist/presentation/pages/wishlist_page.dart';
import '../../features/wishlist/presentation/providers/pending_wishlist_save.dart';
import '../../features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'app_routes.dart';
import 'app_shell.dart';

part 'app_router.g.dart';

const _protectedPrefixes = <String>[
  AppRoutes.cart,
  AppRoutes.checkout,
  AppRoutes.wishlist,
  AppRoutes.orders,
  AppRoutes.profile,
  AppRoutes.notifications,
  '/order-confirmation',
];

const _guestOnlyPaths = <String>[
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
];

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshListenable = _AuthRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refreshListenable,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      if (!auth.isResolved) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (location.startsWith('/reset-password/')) {
        return null;
      }

      if (auth.isAuthenticated) {
        if (location == AppRoutes.splash || _guestOnlyPaths.contains(location)) {
          return AppRoutes.home;
        }
        return null;
      }

      final needsAuth = _protectedPrefixes.any(location.startsWith);
      if (needsAuth) {
        return Uri(
          path: AppRoutes.login,
          queryParameters: {'redirect': location},
        ).toString();
      }

      if (location == AppRoutes.splash) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (context, state) => LoginPage(
          redirectTo: state.uri.queryParameters['redirect'],
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: AppRouteNames.register,
        builder: (context, state) => RegisterPage(
          redirectTo: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRouteNames.resetPassword,
        builder: (context, state) => ResetPasswordPage(
          token: state.pathParameters['token'] ?? '',
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                name: AppRouteNames.categories,
                builder: (context, state) => const CategoriesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wishlist,
                name: AppRouteNames.wishlist,
                builder: (context, state) => const WishlistPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                name: AppRouteNames.cart,
                builder: (context, state) => const CartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRouteNames.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.products,
        name: AppRouteNames.products,
        builder: (context, state) => ProductListPage(
          initialQuery: ProductQuery.fromQueryParameters(
            state.uri.queryParameters,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        name: AppRouteNames.productDetail,
        builder: (context, state) => _ProductDetailRoute(
          slug: state.pathParameters['slug'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.categoryProducts,
        name: AppRouteNames.categoryProducts,
        builder: (context, state) => ProductListPage.forCategory(
          categorySlug: state.pathParameters['slug'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.brandProducts,
        name: AppRouteNames.brandProducts,
        builder: (context, state) => ProductListPage.forBrand(
          brandSlug: state.pathParameters['slug'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: AppRouteNames.search,
        builder: (context, state) => SearchPage(
          initialTerm: state.uri.queryParameters['q'],
        ),
      ),

      GoRoute(
        path: AppRoutes.checkout,
        name: AppRouteNames.checkout,
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: AppRoutes.orderConfirmation,
        name: AppRouteNames.orderConfirmation,
        builder: (context, state) {
          final order = state.extra;
          return order is Order
              ? OrderSuccessPage(order: order)
              : OrderDetailPage(orderId: state.pathParameters['id'] ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: AppRouteNames.orders,
        builder: (context, state) => const OrdersPage(),
        routes: [
          GoRoute(
            path: ':id',
            name: AppRouteNames.orderDetail,
            builder: (context, state) => OrderDetailPage(
              orderId: state.pathParameters['id'] ?? '',
            ),
            routes: [
              GoRoute(
                path: 'track',
                name: AppRouteNames.orderTracking,
                builder: (context, state) => OrderTrackingPage(
                  orderId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        name: AppRouteNames.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: AppRouteNames.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.myReviews,
        name: AppRouteNames.myReviews,
        builder: (context, state) => const MyReviewsPage(),
      ),
      GoRoute(
        path: AppRoutes.recentlyViewed,
        name: AppRouteNames.recentlyViewed,
        builder: (context, state) => const RecentlyViewedPage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRouteNames.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => _RouteNotFound(location: state.uri.path),
  );
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    _lastStatus = ref.read(authProvider).status;
    _subscription = ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (next.status != _lastStatus) {
          _lastStatus = next.status;
          notifyListeners();
        }
      },
    );
  }

  late AuthStatus _lastStatus;
  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

class _ProductDetailRoute extends ConsumerStatefulWidget {
  const _ProductDetailRoute({required this.slug});

  final String slug;

  @override
  ConsumerState<_ProductDetailRoute> createState() =>
      _ProductDetailRouteState();
}

class _ProductDetailRouteState extends ConsumerState<_ProductDetailRoute> {
  bool _replayPendingSave = false;

  @override
  void initState() {
    super.initState();
    _replayPendingSave = ref.read(isAuthenticatedProvider) &&
        ref.read(pendingWishlistSaveProvider.notifier).claim(widget.slug);
  }

  void _onWishlistTap(Product product) {
    if (ref.read(isAuthenticatedProvider)) {
      ref.read(wishlistProvider.notifier).toggle(productId: product.id);
      return;
    }

    ref.read(pendingWishlistSaveProvider.notifier).remember(widget.slug);
    context.push(
      '${AppRoutes.login}'
      '?redirect=${Uri.encodeComponent(AppRoutes.productDetailPath(widget.slug))}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productDetailProvider(widget.slug)).product;

    if (_replayPendingSave && product != null) {
      _replayPendingSave = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(wishlistProvider.notifier).add(productId: product.id);
      });
    }

    return ProductDetailPage(
      slug: widget.slug,
      onAddToCart: (product, variant, quantity) {
        ref.read(cartProvider.notifier).addItem(
              productId: product.id,
              variantId: variant.id,
              quantity: quantity,
            );
      },
      showWishlistButton: true,
      isWishlisted: (product) => ref.watch(isWishlistedProvider(product.id)),
      onWishlistTap: _onWishlistTap,
    );
  }
}

class _RouteNotFound extends StatelessWidget {
  const _RouteNotFound({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_off_outlined, size: 44),
                const SizedBox(height: 20),
                Text(
                  'We could not find $location',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('BACK TO SHOP'),
                ),
              ],
            ),
          ),
        ),
      );
}
