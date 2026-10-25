import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/content/catalog_content.dart';
import '../../state/cart_provider.dart';
import '../../state/catalog_provider.dart';
import '../../state/wishlist_provider.dart';
import '../../widgets/app_image.dart';
import '../../widgets/common.dart';
import '../../widgets/order_summary.dart';
import '../../widgets/product_card.dart';

/// Bag — items, coupon, price details and a sticky "Place order" bar.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(cartTotalsProvider);
    final loading = ref.watch(catalogProvider).isLoading && totals.isEmpty && ref.watch(cartProvider).items.isNotEmpty;
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final inBag = totals.lines.map((l) => l.product.id).toSet();
    final suggestions = (catalog?.bestsellers ?? []).where((p) => !inBag.contains(p.id)).take(8).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(totals.count > 0 ? 'My bag · ${totals.count} item${totals.count == 1 ? '' : 's'}' : 'My bag'),
        actions: [IconButton(icon: const Icon(Icons.favorite_border_rounded), tooltip: 'Wishlist', onPressed: () => context.go('/wishlist'))],
      ),
      bottomNavigationBar: totals.isEmpty
          ? null
          : StickyBar(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatPrice(totals.total), style: AppText.sans(size: 19, weight: FontWeight.w800)),
                        Text('Total incl. shipping', style: AppText.muted(size: 11.5)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: ElevatedButton(onPressed: () => context.push('/checkout'), child: const Text('PLACE ORDER')),
                  ),
                ],
              ),
            ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : totals.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your bag is empty',
              message: 'Diyas, rose candles and gift sets are waiting.',
              actionLabel: 'Start shopping',
              onAction: () => context.go('/'),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                if (totals.remainingForFree != null && totals.remainingForFree! > 0)
                  Container(
                    color: AppColors.sand,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.terracotta),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Add ${formatPrice(totals.remainingForFree!)} more for FREE shipping',
                            style: AppText.sans(size: 13, weight: FontWeight.w700, color: AppColors.cocoa),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (totals.shipping == 0)
                  Container(
                    color: const Color(0xFFE9F7EF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF168A4C)),
                        const SizedBox(width: 10),
                        Text(
                          'Yay! Your order ships for FREE',
                          style: AppText.sans(size: 13, weight: FontWeight.w700, color: const Color(0xFF168A4C)),
                        ),
                      ],
                    ),
                  ),
                for (final l in totals.lines) _CartItem(line: l),
                const CouponRow(),
                const PriceDetails(),
                const SecureNote(),
                if (suggestions.isNotEmpty) ...[
                  const SectionTitle('You may also like', padding: EdgeInsets.fromLTRB(16, 4, 8, 10), action: ''),
                  ProductCarousel(products: suggestions),
                ],
              ],
            ),
    );
  }
}

class _CartItem extends ConsumerWidget {
  const _CartItem({required this.line});
  final CartLine line;

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppImage(line.product.image, width: 56, height: 56, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Remove from bag?', style: AppText.title(size: 16)),
                        Text('Save it to your wishlist to buy later.', style: AppText.muted()),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => Navigator.pop(ctx, 'remove'), child: const Text('REMOVE')),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(onPressed: () => Navigator.pop(ctx, 'wishlist'), child: const Text('MOVE TO WISHLIST')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return;
    if (choice == 'wishlist' && !ref.read(wishlistProvider).contains(line.product.id)) ref.read(wishlistProvider.notifier).toggle(line.product.id);
    ref.read(cartProvider.notifier).remove(line.item.key);
    if (context.mounted) showToast(context, choice == 'wishlist' ? 'Moved to wishlist' : 'Removed from bag');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = line.product;
    final cart = ref.read(cartProvider.notifier);
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push('/product/${p.id}'),
            child: AppImage(p.image, tone: p.tone, width: 92, height: 108, radius: 10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/product/${p.id}'),
                        child: Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sans(size: 14.5, weight: FontWeight.w700),
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.ash),
                      onPressed: () => _remove(context, ref),
                    ),
                  ],
                ),
                Text([p.subtitle.isNotEmpty ? p.subtitle : p.categoryLabel, ?fragranceLabel(line.item.fragrance)].join(' · '), style: AppText.muted(size: 12)),
                const SizedBox(height: 6),
                PriceText(price: p.price, compareAt: p.compareAt, size: 14),
                const SizedBox(height: 10),
                Row(
                  children: [
                    QuantityStepper(value: line.item.quantity, compact: true, onChanged: (v) => cart.setQuantity(line.item.key, v)),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(formatPrice(line.lineTotal), style: AppText.sans(size: 15, weight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
