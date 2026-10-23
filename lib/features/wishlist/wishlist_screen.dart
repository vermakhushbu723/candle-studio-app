import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content/catalog_content.dart';
import '../../state/cart_provider.dart';
import '../../state/catalog_provider.dart';
import '../../state/wishlist_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';

/// Candles saved with the heart button.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(wishlistProvider);
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final items = [for (final id in ids) ?catalog?.product(id)];
    final available = items.where((p) => !p.outOfStock).toList();

    void addAll() {
      for (final p in available) {
        ref.read(cartProvider.notifier).add(p.id, fragrance: p.hasFragrances ? fragrances.first.id : null);
      }
      showToast(context, '${available.length} item${available.length == 1 ? '' : 's'} added to bag');
      context.go('/cart');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(items.isEmpty ? 'Wishlist' : 'Wishlist · ${items.length}'),
        actions: [IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => context.push('/search'))],
      ),
      bottomNavigationBar: available.length < 2
          ? null
          : StickyBar(
              child: ElevatedButton.icon(onPressed: addAll, icon: const Icon(Icons.shopping_bag_outlined), label: Text('ADD ALL ${available.length} TO BAG')),
            ),
      body: catalog == null && ids.isNotEmpty
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Your wishlist is empty',
              message: 'Tap the ♡ on any candle to save it for later.',
              actionLabel: 'Explore candles',
              onAction: () => context.go('/'),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_rounded, size: 16, color: AppColors.danger),
                        const SizedBox(width: 6),
                        Text('Saved on this phone · tap ADD to move to bag', style: AppText.muted(size: 12.5)),
                      ],
                    ),
                  ),
                ),
                ProductSliverGrid(products: items),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
    );
  }
}
