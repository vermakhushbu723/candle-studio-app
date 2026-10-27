import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/content/catalog_content.dart';
import '../../data/models/product.dart';
import '../../state/cart_provider.dart';
import '../../state/catalog_provider.dart';
import '../../widgets/app_image.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';

const _maxPrice = 3000.0;

const sortOptions = {
  'featured': 'Featured',
  'popular': 'Popularity',
  'rating': 'Customer rating',
  'price-asc': 'Price — low to high',
  'price-desc': 'Price — high to low',
};

/// Same filtering and sorting as the website shop.
List<Product> filterProducts(Catalog c, {String line = 'all', String? category, String query = '', RangeValues? price, String sort = 'featured'}) {
  final q = query.trim().toLowerCase();
  final list = c.products
      .where((p) => line == 'all' || p.line == line)
      .where((p) => category == null || c.inCategory(p, category))
      .where((p) => price == null || (p.price >= price.start && p.price <= price.end))
      .where((p) => q.isEmpty || '${p.name} ${p.tagline} ${p.subtitle}'.toLowerCase().contains(q))
      .toList();
  switch (sort) {
    case 'price-asc':
      list.sort((a, b) => a.price - b.price);
    case 'price-desc':
      list.sort((a, b) => b.price - a.price);
    case 'rating':
      list.sort((a, b) => b.rating.compareTo(a.rating));
    case 'popular':
      list.sort((a, b) => b.reviews - a.reviews);
  }
  return list;
}

/// Product listing (opened from categories, banners, search). Sort & Filter live in a bottom bar.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key, this.line, this.category, this.query});
  final String? line;
  final String? category;
  final String? query;

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  late String _line = widget.line ?? 'all';
  late String? _category = widget.category;
  RangeValues _price = const RangeValues(0, _maxPrice);
  String _sort = 'featured';

  int get _filterCount => (_category != null ? 1 : 0) + (_price != const RangeValues(0, _maxPrice) ? 1 : 0);

  Future<void> _openSort() async {
    final v = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader('Sort by'),
            RadioGroup<String>(
              groupValue: _sort,
              onChanged: (v) => Navigator.pop(ctx, v),
              child: Column(
                children: [
                  for (final e in sortOptions.entries)
                    RadioListTile<String>(
                      value: e.key,
                      title: Text(e.value, style: AppText.sans(size: 15)),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (v != null) setState(() => _sort = v);
  }

  Future<void> _openFilters(Catalog catalog) async {
    var category = _category;
    var price = _price;
    final visible = catalog.categories.where((c) => _line == 'all' || c.line == 'all' || c.line == _line).toList();
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.94,
          builder: (_, scroll) => Column(
            children: [
              SheetHeader(
                'Filters',
                trailing: TextButton(
                  onPressed: () => set(() {
                    category = null;
                    price = const RangeValues(0, _maxPrice);
                  }),
                  child: const Text('CLEAR ALL'),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Text('Price', style: AppText.title(size: 15)),
                    RangeSlider(
                      min: 0,
                      max: _maxPrice,
                      divisions: 60,
                      values: price,
                      labels: RangeLabels(formatPrice(price.start), formatPrice(price.end)),
                      onChanged: (v) => set(() => price = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatPrice(price.start), style: AppText.muted()),
                        Text(formatPrice(price.end), style: AppText.muted()),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Category & collection', style: AppText.title(size: 15)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in visible)
                          FilterChip(
                            label: Text('${c.label} (${catalog.countIn(c.id)})'),
                            selected: category == c.id,
                            showCheckmark: false,
                            onSelected: (v) => set(() => category = v ? c.id : null),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              StickyBar(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Close')),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Show ${filterProducts(catalog, line: _line, category: category, price: price).length} results'),
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
    if (applied == true) {
      setState(() {
        _category = category;
        _price = price;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(catalogProvider);
    final bagCount = ref.watch(cartTotalsProvider).count;
    final catalog = async.valueOrNull;
    final cat = catalog?.category(_category);
    final title = cat?.label ?? (widget.query?.isNotEmpty ?? false ? '“${widget.query}”' : (productLines[_line]?.title ?? 'All candles'));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (catalog != null)
              Text(
                '${filterProducts(catalog, line: _line, category: _category, query: widget.query ?? '', price: _price).length} items',
                style: AppText.muted(size: 12),
              ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => context.push('/search')),
          IconButton(
            icon: Badge(
              isLabelVisible: bagCount > 0,
              label: Text('$bagCount'),
              backgroundColor: AppColors.danger,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      bottomNavigationBar: catalog == null
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEFE6DE))),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _openSort,
                          icon: const Icon(Icons.swap_vert_rounded),
                          label: Text(_sort == 'featured' ? 'SORT' : sortOptions[_sort]!.toUpperCase(), overflow: TextOverflow.ellipsis),
                          style: TextButton.styleFrom(foregroundColor: AppColors.charcoal),
                        ),
                      ),
                      const VerticalDivider(width: 1, indent: 12, endIndent: 12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _openFilters(catalog),
                          icon: Badge(
                            isLabelVisible: _filterCount > 0,
                            label: Text('$_filterCount'),
                            backgroundColor: AppColors.terracotta,
                            child: const Icon(Icons.tune_rounded),
                          ),
                          label: const Text('FILTER'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.charcoal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetry(message: '$e', onRetry: () => ref.read(catalogProvider.notifier).refresh()),
        data: (c) {
          final list = filterProducts(c, line: _line, category: _category, query: widget.query ?? '', price: _price, sort: _sort);
          return RefreshIndicator(
            color: AppColors.terracotta,
            onRefresh: () => ref.read(catalogProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    height: 54,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      children: [
                        for (final (id, label) in [(null, 'All'), for (final pc in productCategories) (pc.id, pc.label)])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(label),
                              selected: _category == id,
                              showCheckmark: false,
                              onSelected: (_) => setState(() {
                                _line = 'all';
                                _category = id;
                              }),
                            ),
                          ),
                        if (cat != null && cat.isCollection)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InputChip(
                              label: Text(cat.label),
                              labelStyle: AppText.sans(size: 13, weight: FontWeight.w600, color: Colors.white),
                              selected: true,
                              showCheckmark: false,
                              deleteIconColor: Colors.white,
                              onDeleted: () => setState(() => _category = null),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (cat != null && cat.description.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      height: 92,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppImage(cat.image, tone: cat.tone),
                            const DecoratedBox(
                              decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xE63A1507), Color(0x333A1507)])),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  cat.description,
                                  maxLines: 3,
                                  style: AppText.sans(size: 13, color: Colors.white, weight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                if (list.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No candles found',
                      message: 'Try another category or clear the filters.',
                      actionLabel: 'Clear filters',
                      onAction: () => setState(() {
                        _category = null;
                        _line = 'all';
                        _price = const RangeValues(0, _maxPrice);
                      }),
                    ),
                  )
                else
                  ProductSliverGrid(products: list),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}
