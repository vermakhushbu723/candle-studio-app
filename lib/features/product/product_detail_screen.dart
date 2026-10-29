import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/content/site_content.dart';
import '../../data/models/product.dart';
import '../../state/cart_provider.dart';
import '../../state/catalog_provider.dart';
import '../../state/repositories.dart';
import '../../state/wishlist_provider.dart';
import '../../widgets/app_image.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';
import '../home/widgets/home_sections.dart';

/// Latest copy of one product (GET /products/:slug) — fresh price and stock; works for new admin products too.
final _productProvider = FutureProvider.autoDispose.family<Product, String>((ref, id) => ref.read(catalogRepositoryProvider).product(id));

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cached = ref.watch(catalogProvider).valueOrNull?.product(id);
    final live = ref.watch(_productProvider(id));
    final product = live.valueOrNull ?? cached;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: live.isLoading
            ? const Center(child: CircularProgressIndicator())
            : EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Product not found',
                actionLabel: 'Browse candles',
                onAction: () => context.pushReplacement('/shop'),
              ),
      );
    }
    // An old pack link (…-pack-of-2) opens the product with that pack chosen
    final n = product.id == id ? null : RegExp(r'pack-of-(\d+)$').firstMatch(id)?.group(1);
    final initialPack = n == null ? null : product.packs.where((x) => RegExp('\\b$n\\b').hasMatch(x.label)).firstOrNull?.label;
    return _ProductView(key: ValueKey(product.id), product: product, initialPack: initialPack);
  }
}

class _ProductView extends ConsumerStatefulWidget {
  const _ProductView({super.key, required this.product, this.initialPack});
  final Product product;
  final String? initialPack;

  @override
  ConsumerState<_ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<_ProductView> {
  int _qty = 1;
  late String? _pack = widget.initialPack ?? widget.product.packs.firstOrNull?.label;
  late String? _fragrance = widget.product.fragranceOptions.firstOrNull;
  late String? _color = widget.product.colors.firstOrNull?.name;
  final _gallery = PageController();
  final _scroll = ScrollController();
  bool _collapsed = false;

  Product get p => widget.product;

  List<String> get _images => p.imagesFor(color: _color, pack: _pack);
  int get _price => p.priceFor(_pack);
  int? get _compareAt => p.packs.isEmpty ? p.compareAt : p.packOf(_pack)?.compareAt;

  void _pickPack(String label) {
    setState(() => _pack = label);
    if (_gallery.hasClients) _gallery.jumpToPage(0);
  }

  void _pickColor(String name) {
    setState(() => _color = name);
    if (_gallery.hasClients) _gallery.jumpToPage(0);
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final c = _scroll.offset > MediaQuery.sizeOf(context).width - 120;
      if (c != _collapsed) setState(() => _collapsed = c);
    });
  }

  @override
  void dispose() {
    _gallery.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _buyNow() {
    ref.read(cartProvider.notifier).add(p.id, quantity: _qty, pack: _pack, fragrance: _fragrance, color: _color);
    context.push('/checkout');
  }

  void _share() => Share.share('${p.name} — ${formatPrice(_price)}\n${AppConfig.siteUrl}/product/${p.id}');

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final shipping = ref.watch(shippingProvider);
    final wished = ref.watch(wishlistProvider).contains(p.id);
    final inBag = ref.watch(cartProvider).items.any((i) => i.productId == p.id && i.pack == _pack && i.color == _color && i.fragrance == _fragrance);
    final bagCount = ref.watch(cartTotalsProvider).count;
    final category = catalog?.category(p.category);
    final related = (catalog?.products ?? []).where((x) => x.id != p.id && (x.category == p.category || x.collections.any(p.collections.contains))).take(8).toList();
    final images = _images;
    final packs = p.packs;
    final width = MediaQuery.sizeOf(context).width;

    Widget roundIcon(IconData icon, VoidCallback onTap, {Color? color, Widget? child}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: _collapsed ? Colors.transparent : Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onTap,
          icon: child ?? Icon(icon, color: color ?? AppColors.charcoal, size: 22),
        ),
      ),
    );

    return Scaffold(
      bottomNavigationBar: StickyBar(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: p.outOfStock ? null : () => inBag ? context.go('/cart') : addToCart(context, ref, p, quantity: _qty, pack: _pack, fragrance: _fragrance, color: _color),
                icon: Icon(inBag ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined, size: 20),
                label: Text(inBag ? 'GO TO BAG' : 'ADD TO BAG'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(onPressed: p.outOfStock ? null : _buyNow, child: Text(p.outOfStock ? 'SOLD OUT' : 'BUY NOW')),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: width,
            backgroundColor: Colors.white,
            leading: roundIcon(Icons.arrow_back_rounded, () => context.pop()),
            title: AnimatedOpacity(
              opacity: _collapsed ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.sans(size: 16, weight: FontWeight.w700),
              ),
            ),
            actions: [
              roundIcon(Icons.share_outlined, _share),
              roundIcon(
                Icons.favorite,
                () => toggleWishlist(context, ref, p),
                child: Icon(wished ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: wished ? AppColors.danger : AppColors.charcoal, size: 22),
              ),
              roundIcon(
                Icons.shopping_bag_outlined,
                () => context.go('/cart'),
                child: Badge(
                  isLabelVisible: bagCount > 0,
                  label: Text('$bagCount'),
                  backgroundColor: AppColors.danger,
                  child: const Icon(Icons.shopping_bag_outlined, size: 22, color: AppColors.charcoal),
                ),
              ),
              const SizedBox(width: 6),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _gallery,
                    itemCount: images.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _openViewer(images, i),
                      child: AppImage(images[i], tone: p.tone),
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(20)),
                          child: SmoothPageIndicator(
                            controller: _gallery,
                            count: images.length,
                            effect: const WormEffect(dotHeight: 7, dotWidth: 7, spacing: 6, activeDotColor: AppColors.terracotta, dotColor: AppColors.mist),
                          ),
                        ),
                      ),
                    ),
                  if (p.badge != null) Positioned(left: 14, bottom: 16, child: Pill(p.badge!, size: 11)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & price
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HANDCRAFTED CANDLE${category == null ? '' : ' · ${category.label.toUpperCase()}'}',
                        style: AppText.eyebrow(color: AppColors.gold),
                      ),
                      const SizedBox(height: 6),
                      Text(p.name, style: AppText.sans(size: 20, weight: FontWeight.w700, height: 1.25)),
                      if (p.subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(p.subtitle, style: AppText.muted(size: 13.5)),
                        ),
                      if (p.hasReviews) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            RatingBadge(p.rating),
                            const SizedBox(width: 8),
                            Text('${p.reviews} ratings', style: AppText.muted()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      PriceText(price: _price, compareAt: _compareAt, size: 22),
                      Text('Inclusive of all taxes', style: AppText.muted(size: 11.5)),
                      if (p.stock != null && p.stock! > 0 && p.stock! <= 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Hurry, only ${p.stock} left!',
                            style: AppText.sans(size: 13, weight: FontWeight.w700, color: AppColors.danger),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(p.tagline, style: AppText.sans(size: 14, color: AppColors.ash)),
                    ],
                  ),
                ),
                // Colour
                if (p.colors.isNotEmpty)
                  SectionCard(
                    title: 'Colour: ${_color ?? ''}',
                    child: SizedBox(
                      height: 104,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: p.colors.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final c = p.colors[i];
                          final selected = c.name == _color;
                          return GestureDetector(
                            onTap: () => _pickColor(c.name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 76,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? AppColors.terracotta : AppColors.linen, width: selected ? 2 : 1),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: c.images.isNotEmpty
                                        ? AppImage(c.images.first, tone: p.tone, width: 76)
                                        : Center(
                                            child: CircleAvatar(radius: 20, backgroundColor: AppColors.parse(c.hex, AppColors.linen)),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    child: Text(
                                      c.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppText.sans(size: 11, weight: selected ? FontWeight.w700 : FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                // Pack size
                if (packs.length > 1)
                  SectionCard(
                    title: 'Pack size: ${_pack ?? ''}',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final v in packs)
                          ChoiceChip(
                            label: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.label, style: AppText.sans(size: 13, weight: FontWeight.w600, color: v.label == _pack ? Colors.white : AppColors.charcoal)),
                                Text(
                                  formatPrice(v.price),
                                  style: AppText.sans(size: 11, weight: FontWeight.w700, color: v.label == _pack ? Colors.white : AppColors.ash),
                                ),
                              ],
                            ),
                            selected: v.label == _pack,
                            showCheckmark: false,
                            onSelected: (_) => _pickPack(v.label),
                          ),
                      ],
                    ),
                  ),
                // Fragrance & quantity
                SectionCard(
                  title: p.fragranceOptions.isNotEmpty ? 'Fragrance: ${_fragrance ?? ''}' : 'Quantity',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.fragranceOptions.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final f in p.fragranceOptions)
                              ChoiceChip(
                                label: Text(f, style: AppText.sans(size: 13, weight: FontWeight.w600, color: _fragrance == f ? Colors.white : AppColors.charcoal)),
                                selected: _fragrance == f,
                                showCheckmark: false,
                                onSelected: (_) => setState(() => _fragrance = f),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                      Row(
                        children: [
                          QuantityStepper(value: _qty, onChanged: (v) => setState(() => _qty = v)),
                          const Spacer(),
                          Text(formatPrice(_price * _qty), style: AppText.sans(size: 16, weight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delivery & perks
                SectionCard(
                  title: 'Delivery & services',
                  child: Column(
                    children: [
                      for (final (icon, title, text) in [
                        (Icons.local_shipping_outlined, shipping.short, 'Dispatched same day before 2 PM · metros in 2–3 days'),
                        (Icons.payments_outlined, 'Cash on Delivery available', 'On every order · delivering across ${shipping.deliveryArea}'),
                        (Icons.sync_rounded, '7-day easy returns', 'Damaged in transit? Free replacement'),
                        (Icons.back_hand_outlined, 'Hand-poured in India', 'Made in small batches · packed gift-ready'),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(icon, color: AppColors.terracotta, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: AppText.sans(size: 13.5, weight: FontWeight.w700)),
                                    Text(text, style: AppText.muted(size: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Details
                Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      _expand('Product details', open: true, child: _paragraph('${p.description}${p.bestFor.isEmpty ? '' : '\n\nBest for: ${p.bestFor}'}')),
                      if (p.includes.isNotEmpty) const Divider(),
                      if (p.includes.isNotEmpty) _expand("What's inside the box", child: _bullets(p.includes)),
                      if (p.howToUse.isNotEmpty) const Divider(),
                      if (p.howToUse.isNotEmpty) _expand('How to use', child: _bullets(p.howToUse, numbered: true)),
                      const Divider(),
                      _expand(
                        'Shipping & returns',
                        child: _paragraph(
                          'We deliver only in ${shipping.deliveryArea}. Dispatched same day before 2 PM — Noida & Ghaziabad in 1–2 days, rest of UP in 2–4 days. COD available. ${shipping.sentence}\n\nReturns within 7 days for unused items. Damaged in transit? Share an unboxing video within 48 hours for a free replacement.',
                        ),
                      ),
                    ],
                  ),
                ),
                // Reviews
                SectionTitle(p.hasReviews ? 'Ratings & reviews' : 'What customers say', subtitle: p.hasReviews ? '${p.rating} ★ · ${p.reviews} verified ratings' : 'Loved in homes across India', action: ''),
                SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SizedBox(width: 270, child: ReviewTile(review: reviews[i], showProduct: false)),
                  ),
                ),
                if (related.isNotEmpty) ...[
                  SectionTitle('Similar candles', onAction: () => context.push(category == null ? '/shop' : '/shop?category=${category.id}')),
                  ProductCarousel(products: related),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _expand(String title, {required Widget child, bool open = false}) => ExpansionTile(
    initiallyExpanded: open,
    shape: const Border(),
    collapsedShape: const Border(),
    iconColor: AppColors.terracotta,
    collapsedIconColor: AppColors.ash,
    title: Text(title, style: AppText.sans(size: 15, weight: FontWeight.w700)),
    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    expandedCrossAxisAlignment: CrossAxisAlignment.start,
    children: [child],
  );

  Widget _paragraph(String text) => Text(text, style: AppText.sans(size: 13.5, color: AppColors.ash, height: 1.6));

  Widget _bullets(List<String> items, {bool numbered = false}) => Column(
    children: [
      for (var i = 0; i < items.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              numbered
                  ? CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.terracotta,
                      child: Text(
                        '${i + 1}',
                        style: AppText.sans(size: 10, color: Colors.white, weight: FontWeight.w700),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF168A4C)),
                    ),
              const SizedBox(width: 10),
              Expanded(child: Text(items[i], style: AppText.sans(size: 13.5, height: 1.45))),
            ],
          ),
        ),
    ],
  );

  void _openViewer(List<String> images, int start) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
          body: PageView.builder(
            controller: PageController(initialPage: start),
            itemCount: images.length,
            itemBuilder: (_, i) => InteractiveViewer(
              child: Center(child: AppImage(images[i], fit: BoxFit.contain)),
            ),
          ),
        ),
      ),
    );
  }
}
