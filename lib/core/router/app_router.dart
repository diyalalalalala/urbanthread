import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/reset_password_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/authentication/presentation/pages/verify_email_page.dart';
import '../../features/authentication/presentation/providers/auth_notifier.dart';
import '../../features/authentication/presentation/providers/auth_state.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/providers/cart_notifier.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/order_tracking_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/domain/entities/product_query.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/my_reviews_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/recently_viewed_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/wishlist/presentation/pages/wishlist_page.dart';
import 'app_routes.dart';
import 'app_shell.dart';

part 'app_router.g.dart';

/// Routes that require a session.
///
/// These mirror the backend's `authenticate` middleware. Guarding them here
/// is a UX decision, not a security one — the server is the real gate; this
/// just means a signed-out user gets a login screen instead of a 401 toast.
const _protectedPrefixes = <String>[
  AppRoutes.cart,
  AppRoutes.checkout,
  AppRoutes.wishlist,
  AppRoutes.orders,
  AppRoutes.profile,
  AppRoutes.notifications,
];

/// Routes a signed-in user has no business seeing.
const _guestOnlyPaths = <String>[
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
];

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // A plain `ref.watch` would rebuild the whole GoRouter on every auth
  // change, discarding the navigation stack. Listening instead lets the
  // existing router re-evaluate `redirect` in place.
  final refreshListenable = _AuthRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refreshListenable,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      // The token is still being checked. Hold on the splash rather than
      // guessing — sending a signed-in user to login and then bouncing them
      // back reads as a flicker on every cold start.
      if (!auth.isResolved) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // Verification links must open regardless of session state: the link is
      // often opened on a device that has never signed in.
      if (location.startsWith('/verify-email/') ||
          location.startsWith('/reset-password/')) {
        return null;
      }

      if (auth.isAuthenticated) {
        if (location == AppRoutes.splash || _guestOnlyPaths.contains(location)) {
          return AppRoutes.home;
        }
        return null;
      }

      // Signed out, heading somewhere that needs a session: carry the
      // destination so login can resume it instead of dumping the user home.
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

      // ── Auth ───────────────────────────────────────────────────────────
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
          // Sent via `extra` from the login screen so a redirect survives the
          // detour through registration.
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
      GoRoute(
        path: AppRoutes.verifyEmail,
        name: AppRouteNames.verifyEmail,
        builder: (context, state) => VerifyEmailPage(
          token: state.pathParameters['token'] ?? '',
        ),
      ),

      // ── Tabs ───────────────────────────────────────────────────────────
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

      // ── Catalogue ──────────────────────────────────────────────────────
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
          // Detail is slug-only — the backend registers no `/:id` route, and
          // passing an ObjectId here would 404.
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

      // ── Checkout and orders ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.checkout,
        name: AppRouteNames.checkout,
        builder: (context, state) => const CheckoutPage(),
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

      // ── Account ────────────────────────────────────────────────────────
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

/// Bridges the auth notifier to GoRouter's [Listenable]-based refresh.
///
/// Only genuine sign-in/sign-out transitions are forwarded. Firing on every
/// [AuthState] change would re-run `redirect` for unrelated updates — a
/// failed login attempt, a submitting flag — and each of those would reset
/// the navigation stack.
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

/// Supplies the product page's add-to-cart action.
///
/// The products feature deliberately does not import the cart feature, so the
/// two are joined here at the route — the one place that already knows about
/// both.
class _ProductDetailRoute extends ConsumerWidget {
  const _ProductDetailRoute({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ProductDetailPage(
        slug: slug,
        onAddToCart: (product, variant, quantity) {
          ref.read(cartProvider.notifier).addItem(
                productId: product.id,
                variantId: variant.id,
                quantity: quantity,
              );
        },
      );
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
