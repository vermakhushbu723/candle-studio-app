import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../data/content/catalog_content.dart';
import '../../../data/content/site_content.dart';
import '../../../data/models/category.dart';
import '../../../services/launcher.dart';
import '../../../state/catalog_provider.dart';
import '../../../widgets/app_image.dart';
import '../../../widgets/common.dart';

/// Tappable search field that opens the Search screen.
class SearchField extends StatelessWidget {
  const SearchField({super.key, this.hint = 'Search candles, gifts, scents…'});
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/search'),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.linen),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.ash),
              const SizedBox(width: 10),
              Expanded(
                child: Text(hint, style: AppText.muted(size: 14), overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.mic_none_rounded, color: AppColors.mist, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.image, required this.kicker, required this.title, required this.cta, required this.route});
  final String image;
  final String kicker;
  final String title;
  final String cta;
  final String route;
}

/// Auto-sliding offer banners.
class BannerCarousel extends ConsumerStatefulWidget {
  const BannerCarousel({super.key});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  final _page = PageController(viewportFraction: 0.92);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_page.hasClients) return;
      final next = ((_page.page ?? 0).round() + 1) % _slides.length;
      _page.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  List<_Slide> get _slides {
    final catalog = ref.read(catalogProvider).valueOrNull;
    final festive = catalog?.collections.where((c) => c.isFestive).toList() ?? const <Category>[];
    return [
      const _Slide(
        image: '/images/products/catalog/designer-diya.jpg',
        kicker: 'DIWALI · POOJA',
        title: 'Designer wax diyas\n& lotus bowls',
        cta: 'Shop Pooja & Diyas',
        route: '/shop?category=pooja-festive',
      ),
      const _Slide(image: SiteImages.livingRoom, kicker: 'FOLLOW & SAVE', title: 'Follow us &\nget 10% off', cta: 'Unlock coupon', route: '/follow'),
      if (festive.isNotEmpty)
        _Slide(
          image: festive.first.image ?? SiteImages.urli,
          kicker: 'FESTIVE SPECIAL',
          title: festive.first.label,
          cta: 'Explore',
          route: '/shop?category=${festive.first.id}',
        ),
      const _Slide(
        image: '/images/products/catalog/rose-bubble.jpg',
        kicker: 'HAND-POURED IN INDIA',
        title: 'Roses & bubble\ncandles to gift',
        cta: 'Shop Bouquets & Roses',
        route: '/shop?category=floral',
      ),
      const _Slide(
        image: SiteImages.urli,
        kicker: 'CORPORATE & WEDDING',
        title: 'Gift hampers\nfrom 25 units',
        cta: 'Get a quote',
        route: '/contact?topic=bulk',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    return Column(
      children: [
        SizedBox(
          height: 178,
          child: PageView.builder(
            controller: _page,
            itemCount: slides.length,
            itemBuilder: (_, i) {
              final s = slides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push(s.route),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImage(s.image),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0xE63A1507), Color(0x803A1507), Color(0x003A1507)], stops: [0, 0.55, 1]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s.kicker, style: AppText.eyebrow(color: AppColors.caramel)),
                              const SizedBox(height: 6),
                              Text(s.title, maxLines: 2, style: AppText.serif(size: 23, color: Colors.white, height: 1.15)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(color: AppColors.caramel, borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  s.cta,
                                  style: AppText.sans(size: 12, weight: FontWeight.w800, color: AppColors.charcoal),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _page,
          count: slides.length,
          effect: const ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
            spacing: 5,
            activeDotColor: AppColors.terracotta,
            dotColor: AppColors.mist,
          ),
        ),
      ],
    );
  }
}

/// Round category shortcuts (each category & collection).
class CategoryCircles extends ConsumerWidget {
  const CategoryCircles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final items = <(String, String?, String, String?)>[
      for (final c in [...productCategories, ...?catalog?.collections]) (c.label, c.image, '/shop?category=${c.id}', c.tone),
    ];
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (label, image, route, tone) = items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(route),
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.caramel, width: 1.5),
                    ),
                    child: ClipOval(child: AppImage(image, tone: tone)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label.replaceAll(' Collection', ''),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(size: 11, weight: FontWeight.w600, height: 1.15),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "Use GLOW10" coupon strip with copy.
class CouponStrip extends StatelessWidget {
  const CouponStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFF1E6), AppColors.sand]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.caramel.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: AppColors.terracotta),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('10% off your first order', style: AppText.sans(size: 14, weight: FontWeight.w800)),
                  Text('Use code GLOW10 at checkout', style: AppText.muted(size: 12)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'GLOW10'));
                showToast(context, 'GLOW10 copied');
              },
              child: const Text('COPY'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Free shipping · COD · hand-poured · gift-ready.
class TrustRow extends ConsumerWidget {
  const TrustRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ship = ref.watch(shippingProvider).perk;
    final items = [
      (Icons.local_shipping_outlined, ship.title, ship.text),
      (Icons.payments_outlined, 'COD', '22,000+ pins'),
      (Icons.back_hand_outlined, 'Hand-poured', 'Made in India'),
      (Icons.card_giftcard_rounded, 'Gift-ready', 'Free note'),
    ];
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          for (final (icon, title, text) in items)
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.sand,
                    child: Icon(icon, size: 20, color: AppColors.terracotta),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(size: 11.5, weight: FontWeight.w700),
                  ),
                  Text(text, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.muted(size: 10.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Portrait collection cards (festive & curated).
class CollectionRail extends ConsumerWidget {
  const CollectionRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final items = catalog?.collections ?? const <Category>[];
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = items[i];
          return SizedBox(
            width: 136,
            child: Material(
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.push('/shop?category=${c.id}'),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(c.image, tone: c.tone),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.center, colors: [Color(0xD93A1507), Colors.transparent]),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.label,
                            maxLines: 2,
                            style: AppText.sans(size: 13.5, weight: FontWeight.w700, color: Colors.white, height: 1.2),
                          ),
                          Text('${catalog!.countIn(c.id)} items', style: AppText.sans(size: 11, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Festive & Gifting vs Home & Décor tiles.
class LineTiles extends ConsumerWidget {
  const LineTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).valueOrNull;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final line in productLines.values) ...[
            if (line.id != 'festive') const SizedBox(width: 10),
            Expanded(
              child: Material(
                color: line.id == 'festive' ? AppColors.shell : AppColors.sand,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/shop?category=${productCategories.firstWhere((c) => c.line == line.id).id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(aspectRatio: 1.25, child: AppImage(catalog?.product(line.productId)?.image)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(line.title, style: AppText.sans(size: 14, weight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(line.perks.join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.muted(size: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Banner card leading somewhere (scent quiz, Follow & Save, gifting).
class PromoCard extends StatelessWidget {
  const PromoCard({super.key, required this.icon, required this.title, required this.text, required this.cta, required this.onTap, this.dark = true});
  final IconData icon;
  final String title;
  final String text;
  final String cta;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.charcoal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        color: dark ? AppColors.charcoal : Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: dark
                ? const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6C2A12), AppColors.charcoal]),
                  )
                : null,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: dark ? Colors.white12 : AppColors.sand,
                  child: Icon(icon, color: dark ? AppColors.caramel : AppColors.terracotta),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.sans(size: 15, weight: FontWeight.w800, color: fg),
                      ),
                      const SizedBox(height: 2),
                      Text(text, style: AppText.sans(size: 12.5, color: fg.withValues(alpha: 0.75))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(color: dark ? AppColors.caramel : AppColors.terracotta, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    cta,
                    style: AppText.sans(size: 11.5, weight: FontWeight.w800, color: dark ? AppColors.charcoal : Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pour · Insert · Ignite · Refresh — compact horizontal steps.
class HowItWorksRail extends StatelessWidget {
  const HowItWorksRail({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 214,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: howItWorks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final s = howItWorks[i];
          return SizedBox(
            width: 168,
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImage(s.image),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: AppColors.terracotta,
                            child: Text(
                              '${i + 1}',
                              style: AppText.sans(size: 12, weight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, style: AppText.sans(size: 14, weight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(s.body, maxLines: 4, overflow: TextOverflow.ellipsis, style: AppText.muted(size: 11.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Customer reviews rail with the overall rating.
class ReviewsRail extends StatelessWidget {
  const ReviewsRail({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: reviews.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(width: 270, child: ReviewTile(review: reviews[i])),
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review, this.showProduct = true});
  final Review review;
  final bool showProduct;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.terracotta,
                child: Text(
                  initials(review.name),
                  style: AppText.sans(size: 11, weight: FontWeight.w700, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.sans(size: 13, weight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF168A4C)),
                      ],
                    ),
                    Text(review.location, style: AppText.muted(size: 11)),
                  ],
                ),
              ),
              RatingBadge(review.rating.toDouble(), small: true),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(review.quote, overflow: TextOverflow.fade, style: AppText.sans(size: 13, height: 1.45)),
          ),
          if (showProduct)
            Text(
              review.product,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.sans(size: 11, color: AppColors.gold, weight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}

/// Small brand footer at the end of Home.
class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
      color: AppColors.charcoal,
      child: Column(
        children: [
          Image.asset('assets/images/logo_light.png', height: 92),
          const SizedBox(height: 10),
          Text('Handmade in India · Women-owned business', style: AppText.sans(size: 12, color: AppColors.cream.withValues(alpha: 0.7))),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (label, route) in [('About', '/about'), ('FAQs', '/faq'), ('Contact', '/contact'), ('Policies', '/policies/shipping')])
                ActionChip(
                  label: Text(label),
                  labelStyle: AppText.sans(size: 12, weight: FontWeight.w600, color: AppColors.cream),
                  backgroundColor: Colors.white10,
                  side: const BorderSide(color: Colors.white24),
                  onPressed: () => context.push(route),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => Launcher.open(Site.instagram),
                icon: const Icon(Icons.camera_alt_outlined, color: AppColors.caramel),
              ),
              IconButton(
                onPressed: () => Launcher.open(Site.facebook),
                icon: const Icon(Icons.facebook_rounded, color: AppColors.caramel),
              ),
              IconButton(
                onPressed: Launcher.whatsapp,
                icon: const Icon(Icons.chat_outlined, color: AppColors.caramel),
              ),
              IconButton(
                onPressed: Launcher.review,
                icon: const Icon(Icons.star_border_rounded, color: AppColors.caramel),
              ),
            ],
          ),
          Text('v1.0.0', style: AppText.sans(size: 10, color: AppColors.cream.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
