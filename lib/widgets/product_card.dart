import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/content/catalog_content.dart';
import '../data/models/product.dart';
import '../state/cart_provider.dart';
import '../state/wishlist_provider.dart';
import 'app_image.dart';
import 'common.dart';

/// Adds to the cart and offers a shortcut to it (product cards, product page, chatbot).
void addToCart(BuildContext context, WidgetRef ref, Product product, {int quantity = 1, String? fragrance}) {
  ref.read(cartProvider.notifier).add(product.id, quantity: quantity, fragrance: fragrance ?? (product.hasFragrances ? fragrances.first.id : null));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Added to bag · ${product.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
        action: SnackBarAction(label: 'VIEW BAG', textColor: AppColors.caramel, onPressed: () => context.go('/cart')),
      ),
    );
}

void toggleWishlist(BuildContext context, WidgetRef ref, Product product) {
  final saved = ref.read(wishlistProvider.notifier).toggle(product.id);
  showToast(context, saved ? 'Saved to wishlist' : 'Removed from wishlist');
}

/// Grid/rail product tile in shopping-app style.
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, this.width});
  final Product product;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wished = ref.watch(wishlistProvider).contains(product.id);
    final inBag = ref.watch(cartProvider).items.any((i) => i.productId == product.id);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          onTap: () => context.push('/product/${product.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(product.image, tone: product.tone),
                    if (product.badge != null)
                      Positioned(left: 8, top: 8, child: Pill(product.badge!, color: AppColors.charcoal.withValues(alpha: 0.85), size: 9.5)),
                    if (product.outOfStock)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.6),
                          alignment: Alignment.center,
                          child: Pill('SOLD OUT', color: AppColors.ash, textColor: Colors.white, size: 10),
                        ),
                      ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.9)),
                        onPressed: () => toggleWishlist(context, ref, product),
                        icon: Icon(
                          wished ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 19,
                          color: wished ? AppColors.danger : AppColors.charcoal,
                        ),
                        tooltip: 'Wishlist',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.lineLabel.toUpperCase(),
                        style: AppText.sans(size: 9.5, weight: FontWeight.w700, color: AppColors.gold).copyWith(letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(size: 13.5, weight: FontWeight.w600, height: 1.25),
                      ),
                      const SizedBox(height: 4),
                      RatingBadge(product.rating, count: product.reviews, small: true),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: PriceText(price: product.price, compareAt: product.compareAt, size: 14),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            height: 30,
                            child: OutlinedButton(
                              onPressed: product.outOfStock ? null : () => inBag ? context.go('/cart') : addToCart(context, ref, product),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                backgroundColor: inBag ? AppColors.sand : Colors.white,
                                textStyle: AppText.sans(size: 12, weight: FontWeight.w800),
                              ),
                              child: Text(inBag ? 'IN BAG' : 'ADD'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Text block height under the square image (scales with the phone's font size).
double _infoHeight(BuildContext context) => 132 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.35);

/// Two-column product grid inside a CustomScrollView.
class ProductSliverGrid extends StatelessWidget {
  const ProductSliverGrid({super.key, required this.products, this.padding = const EdgeInsets.symmetric(horizontal: 12)});
  final List<Product> products;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width > 700 ? 3 : 2;
    final width = (MediaQuery.sizeOf(context).width - padding.horizontal - 10 * (columns - 1)) / columns;
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: width + _infoHeight(context),
        ),
        delegate: SliverChildBuilderDelegate((_, i) => ProductCard(product: products[i]), childCount: products.length),
      ),
    );
  }
}

/// Horizontal product rail.
class ProductCarousel extends StatelessWidget {
  const ProductCarousel({super.key, required this.products, this.cardWidth = 160, this.padding = const EdgeInsets.symmetric(horizontal: 16)});
  final List<Product> products;
  final double cardWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardWidth + _infoHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ProductCard(product: products[i], width: cardWidth),
      ),
    );
  }
}
