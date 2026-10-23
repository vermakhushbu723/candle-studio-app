import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content/catalog_content.dart';
import '../../data/models/category.dart';
import '../../state/catalog_provider.dart';
import '../../widgets/app_image.dart';
import '../../widgets/common.dart';
import '../home/widgets/home_sections.dart';

class _Group {
  const _Group(this.label, this.icon, this.items, this.allRoute, this.banner);
  final String label;
  final IconData icon;
  final List<Category> items;
  final String? allRoute;
  final String? banner;
}

/// Categories tab — groups on the left, their categories as a grid on the right.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  int _selected = 0;

  List<_Group> _groups(Catalog c) => [
    _Group(
      'Pearled',
      Icons.bubble_chart_outlined,
      productCategories.where((x) => x.line == 'pearled').toList(),
      '/shop?line=pearled',
      productLines['pearled']!.description,
    ),
    _Group(
      'Handcrafted',
      Icons.local_fire_department_outlined,
      productCategories.where((x) => x.line == 'handcrafted').toList(),
      '/shop?line=handcrafted',
      productLines['handcrafted']!.description,
    ),
    _Group(
      'Festive',
      Icons.celebration_outlined,
      c.collections.where((x) => x.isFestive).toList(),
      null,
      'Diwali, Christmas, Valentine’s and New Year specials.',
    ),
    _Group(
      'Collections',
      Icons.style_outlined,
      c.collections.where((x) => !x.isFestive).toList(),
      null,
      'Curated edits for every mood and corner of your home.',
    ),
  ].where((g) => g.items.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => context.push('/search')),
          IconButton(icon: const Icon(Icons.storefront_outlined), tooltip: 'All candles', onPressed: () => context.push('/shop')),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetry(message: '$e', onRetry: () => ref.read(catalogProvider.notifier).refresh()),
        data: (c) {
          final groups = _groups(c);
          final g = groups[_selected.clamp(0, groups.length - 1)];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left rail
              Container(
                width: 92,
                color: Colors.white,
                child: ListView(
                  children: [
                    for (var i = 0; i < groups.length; i++)
                      InkWell(
                        onTap: () => setState(() => _selected = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
                          decoration: BoxDecoration(
                            color: i == _selected ? AppTheme.background : Colors.white,
                            border: Border(left: BorderSide(color: i == _selected ? AppColors.terracotta : Colors.transparent, width: 3)),
                          ),
                          child: Column(
                            children: [
                              Icon(groups[i].icon, color: i == _selected ? AppColors.terracotta : AppColors.ash),
                              const SizedBox(height: 6),
                              Text(
                                groups[i].label,
                                textAlign: TextAlign.center,
                                style: AppText.sans(
                                  size: 12,
                                  weight: i == _selected ? FontWeight.w800 : FontWeight.w500,
                                  color: i == _selected ? AppColors.terracotta : AppColors.charcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Right content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: [
                    if (g.banner != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.charcoal, Color(0xFF6C2A12)]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.label.toUpperCase(), style: AppText.eyebrow(color: AppColors.caramel)),
                            const SizedBox(height: 4),
                            Text(g.banner!, style: AppText.sans(size: 13, color: Colors.white.withValues(alpha: 0.9))),
                            if (g.allRoute != null) ...[
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () => context.push(g.allRoute!),
                                child: Text(
                                  'Shop all ${g.label} →',
                                  style: AppText.sans(size: 13, weight: FontWeight.w800, color: AppColors.caramel),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: g.items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (_, i) {
                        final cat = g.items[i];
                        return AppCard(
                          padding: const EdgeInsets.all(8),
                          onTap: () => context.push('/shop?category=${cat.id}'),
                          child: Column(
                            children: [
                              Expanded(
                                child: AppImage(cat.image, tone: cat.tone, radius: 10, width: double.infinity),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cat.label,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: AppText.sans(size: 12.5, weight: FontWeight.w700, height: 1.2),
                              ),
                              Text('${c.countIn(cat.id)} items', style: AppText.muted(size: 11)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      onTap: () => context.push('/scent-finder'),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.terracotta),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Can’t decide? Take the scent quiz', style: AppText.sans(size: 13, weight: FontWeight.w700)),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.mist),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Every collection and category as one list (from Home → "View all").
class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('All collections')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetry(message: '$e', onRetry: () => ref.read(catalogProvider.notifier).refresh()),
        data: (c) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SectionTitle('Collections', subtitle: 'Festive specials & curated edits', action: ''),
            const CollectionRail(),
            const SectionTitle('Categories', action: ''),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final cat in productCategories)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      onTap: () => context.push('/shop?category=${cat.id}'),
                      child: Row(
                        children: [
                          AppImage(cat.image, tone: cat.tone, width: 56, height: 56, radius: 10),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat.label, style: AppText.sans(size: 14.5, weight: FontWeight.w700)),
                                Text('${productLines[cat.line]?.title ?? ''} · ${c.countIn(cat.id)} items', style: AppText.muted(size: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.mist),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
