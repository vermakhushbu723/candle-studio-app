import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/account_screen.dart';
import '../../features/account/edit_profile_screen.dart';
import '../../features/account/notification_settings.dart';
import '../../features/auth/login_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/contact/contact_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/widgets/scent_finder.dart';
import '../../features/info/about_screen.dart';
import '../../features/info/faq_screen.dart';
import '../../features/info/not_found_screen.dart';
import '../../features/info/policy_screen.dart';
import '../../features/offers/follow_offer_screen.dart';
import '../../features/orders/my_orders_screen.dart';
import '../../features/orders/track_order_screen.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/shop/categories_screen.dart';
import '../../features/shop/search_screen.dart';
import '../../features/shop/shop_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/support/chat_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../services/launcher.dart';
import '../config/app_config.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Slide-in transition used for every pushed screen (native Android/iOS feel).
Page<void> _page(GoRouterState s, Widget child) => MaterialPage<void>(key: s.pageKey, child: child);

GoRoute _screen(String path, Widget Function(GoRouterState s) build) =>
    GoRoute(parentNavigatorKey: rootNavigatorKey, path: path, pageBuilder: (_, s) => _page(s, build(s)));

/// Every screen of the app. Tabs (Home, Categories, Wishlist, Bag, Account) keep their own history;
/// everything else opens full-screen on top.
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  errorBuilder: (_, _) => const NotFoundScreen(),
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/categories', builder: (_, _) => const CategoriesScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/wishlist', builder: (_, _) => const WishlistScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/cart', builder: (_, _) => const CartScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/account', builder: (_, _) => const AccountScreen())],
        ),
      ],
    ),
    _screen(
      '/shop',
      (s) => ShopScreen(
        key: ValueKey(s.uri.query),
        line: s.uri.queryParameters['line'],
        category: s.uri.queryParameters['category'],
        query: s.uri.queryParameters['q'],
      ),
    ),
    _screen('/search', (_) => const SearchScreen()),
    _screen('/product/:id', (s) => ProductDetailScreen(id: s.pathParameters['id']!)),
    _screen('/collections', (_) => const CollectionsScreen()),
    _screen('/checkout', (_) => const CheckoutScreen()),
    _screen('/login', (s) => LoginScreen(next: s.uri.queryParameters['next'])),
    _screen('/profile', (_) => const EditProfileScreen()),
    _screen('/notifications', (_) => const NotificationsScreen()),
    _screen('/orders', (_) => const MyOrdersScreen()),
    _screen('/track-order', (s) => TrackOrderScreen(orderId: s.uri.queryParameters['order'], contact: s.uri.queryParameters['contact'])),
    _screen('/follow', (_) => const FollowOfferScreen()),
    _screen('/about', (_) => const AboutScreen()),
    _screen('/faq', (_) => const FaqScreen()),
    _screen('/contact', (s) => ContactScreen(topic: s.uri.queryParameters['topic'])),
    _screen('/policies', (_) => const PoliciesScreen()),
    _screen('/policies/:id', (s) => PolicyScreen(id: s.pathParameters['id']!)),
    _screen('/disclaimer', (_) => const PolicyScreen(id: 'disclaimer')),
    _screen('/chat', (_) => const ChatScreen()),
    _screen('/scent-finder', (_) => const ScentFinderScreen()),
  ],
);

/// Opens a link from a push notification or the chatbot: website URLs become app screens,
/// anything else (Google review page, Instagram…) opens in the browser.
void openLink(String link) {
  var path = link;
  if (link.startsWith(AppConfig.siteUrl)) path = link.substring(AppConfig.siteUrl.length);
  if (path.startsWith('http')) {
    Launcher.open(path);
    return;
  }
  if (path.isEmpty || path == '/') return appRouter.go('/');
  if (path == '/login') path = '/account';
  if (['/cart', '/wishlist', '/account', '/categories'].contains(path)) return appRouter.go(path);
  appRouter.push(path.startsWith('/follow') ? '/follow' : path);
}
