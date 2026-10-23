import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../state/cart_provider.dart';
import '../../state/wishlist_provider.dart';
import '../../widgets/common.dart';
import 'push_prompt.dart';

/// Bottom navigation: Home · Categories · Wishlist · Bag · Account.
/// Back on a tab other than Home goes to Home; back on Home asks twice before closing the app.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  DateTime? _lastBack;

  void _onBack() {
    if (widget.shell.currentIndex != 0) {
      widget.shell.goBranch(0);
      return;
    }
    final now = DateTime.now();
    if (_lastBack != null && now.difference(_lastBack!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
    } else {
      _lastBack = now;
      showToast(context, 'Press back again to exit');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    final cartCount = ref.watch(cartTotalsProvider).count;
    final wishCount = ref.watch(wishlistProvider).length;

    Widget badge(int n, IconData icon) => Badge(isLabelVisible: n > 0, label: Text('$n'), backgroundColor: AppColors.danger, child: Icon(icon));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        body: PushPrompt(child: shell),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          // Tapping the current tab again goes back to its first screen
          onDestinationSelected: (i) {
            HapticFeedback.selectionClick();
            shell.goBranch(i, initialLocation: i == shell.currentIndex);
          },
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Categories'),
            NavigationDestination(
              icon: badge(wishCount, Icons.favorite_border_rounded),
              selectedIcon: badge(wishCount, Icons.favorite_rounded),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: badge(cartCount, Icons.shopping_bag_outlined),
              selectedIcon: badge(cartCount, Icons.shopping_bag_rounded),
              label: 'Bag',
            ),
            const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Account'),
          ],
        ),
      ),
    );
  }
}
