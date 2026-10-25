import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product.dart';
import '../../state/catalog_provider.dart';
import '../../state/offer_provider.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';
import 'widgets/home_sections.dart';

/// Home — shopping-app layout: search, banners, categories, offers and product rails.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final user = ref.watch(sessionProvider);
    final offer = ref.watch(followOfferProvider).valueOrNull;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.terracotta,
        edgeOffset: 120,
        onRefresh: () async {
          await ref.read(catalogProvider.notifier).refresh();
          ref.invalidate(followOfferProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Colors.white,
              titleSpacing: 12,
              toolbarHeight: 58,
              title: const BrandLogo(size: 32),
              actions: [
                IconButton(tooltip: 'Track order', icon: const Icon(Icons.local_shipping_outlined), onPressed: () => context.push('/track-order')),
                IconButton(tooltip: 'Chat with us', icon: const Icon(Icons.support_agent_rounded), onPressed: () => context.push('/chat')),
                const SizedBox(width: 4),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(58),
                child: Padding(padding: EdgeInsets.fromLTRB(12, 2, 12, 12), child: SearchField()),
              ),
            ),
            ...catalog.when(
              loading: () => [const SliverToBoxAdapter(child: _HomeSkeleton())],
              error: (e, _) => [
                SliverFillRemaining(
                  child: ErrorRetry(message: '$e', onRetry: () => ref.read(catalogProvider.notifier).refresh()),
                ),
              ],
              data: (c) => [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                          child: Text('Hi ${user.name.split(' ').first}, find your glow ✨', style: AppText.sans(size: 15, weight: FontWeight.w700)),
                        ),
                      const SizedBox(height: 14),
                      const BannerCarousel(),
                      const SizedBox(height: 14),
                      const CategoryCircles(),
                      const CouponStrip(),
                      _rail(context, 'Bestsellers', 'Our most-loved designs', c.bestsellers, '/shop'),
                      const SectionTitle('Shop by collection', subtitle: 'Festive specials & curated edits'),
                      const CollectionRail(),
                      _rail(
                        context,
                        'Festive & Pooja',
                        'Diyas, lotus bowls & sweet-shop candles',
                        c.products.where((p) => ['pooja-festive', 'food-inspired'].contains(p.category)).toList(),
                        '/shop?category=pooja-festive',
                      ),
                      const SectionTitle('Shop by occasion', action: ''),
                      const LineTiles(),
                      if (offer != null && offer.enabled && offer.coupon == null)
                        PromoCard(
                          icon: Icons.card_giftcard_rounded,
                          title: 'Follow us & get ${offer.percent}% off',
                          text: 'Follow Jyotessa on Instagram, Facebook & Google',
                          cta: 'UNLOCK',
                          onTap: () => context.push('/follow'),
                        ),
                      _rail(
                        context,
                        'Roses & Bubbles',
                        'Rose bouquets, bubble cubes & gel glasses',
                        c.products.where((p) => ['floral', 'bubble-candles', 'jars-glass'].contains(p.category)).toList(),
                        '/shop?category=floral',
                      ),
                      PromoCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Not sure which candle?',
                        text: 'Answer 3 quick questions — we’ll match you',
                        cta: 'TAKE QUIZ',
                        dark: false,
                        onTap: () => context.push('/scent-finder'),
                      ),
                      _rail(context, 'Gifting picks', 'Ready to gift, beautifully packed', c.products.where((p) => p.moods.contains('gift')).toList(), '/shop'),
                      const SectionTitle('Candle care', subtitle: 'Four steps to a perfect burn', action: 'Learn more'),
                      const HowItWorksRail(),
                      SectionTitle('Customer reviews', subtitle: 'Loved in homes across India', action: 'About us', onAction: () => context.push('/about')),
                      const ReviewsRail(),
                      PromoCard(
                        icon: Icons.business_center_outlined,
                        title: 'Corporate & wedding gifting',
                        text: 'Custom hampers with your branding, from 25 units',
                        cta: 'GET QUOTE',
                        onTap: () => context.push('/contact?topic=bulk'),
                      ),
                      const TrustRow(),
                      const HomeFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rail(BuildContext context, String title, String subtitle, List<Product> products, String route) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title, subtitle: subtitle, onAction: () => context.push(route)),
        ProductCarousel(products: products.take(10).toList()),
      ],
    );
  }
}

/// Grey placeholders while the catalogue loads.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box(double w, double h, [double r = 12]) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r)),
    );
    return Shimmer.fromColors(
      baseColor: AppColors.linen,
      highlightColor: AppTheme.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            box(double.infinity, 170, 16),
            const SizedBox(height: 20),
            Row(
              children: [for (var i = 0; i < 5; i++) Padding(padding: const EdgeInsets.only(right: 12), child: box(56, 56, 28))],
            ),
            const SizedBox(height: 24),
            box(140, 18),
            const SizedBox(height: 12),
            Row(children: [box(150, 230), const SizedBox(width: 10), box(150, 230)]),
          ],
        ),
      ),
    );
  }
}
