import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../state/catalog_provider.dart';
import '../../widgets/app_image.dart';
import '../../widgets/common.dart';
import 'shop_screen.dart';

const _popular = ['Pearled kit', 'Chai', 'Rose', 'Diwali', 'Lavender', 'Gift set', 'Refill', 'Bouquet'];

/// Search — recent and popular searches, live suggestions while typing.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _q = TextEditingController();
  List<String> _recent = (LocalStorage.read<List<dynamic>>(LocalStorage.recentSearches) ?? []).map((e) => '$e').toList();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _submit(String text) {
    final q = text.trim();
    if (q.isEmpty) return;
    _recent = [q, ..._recent.where((r) => r.toLowerCase() != q.toLowerCase())].take(8).toList();
    LocalStorage.write(LocalStorage.recentSearches, _recent);
    context.pushReplacement('/shop?q=${Uri.encodeComponent(q)}');
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider).valueOrNull;
    final q = _q.text.trim();
    final results = catalog == null || q.isEmpty ? const [] : filterProducts(catalog, query: q).take(12).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _q,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
          onSubmitted: _submit,
          decoration: InputDecoration(
            hintText: 'Search candles, gifts, scents…',
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            suffixIcon: q.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(_q.clear)),
          ),
        ),
        actions: const [SizedBox(width: 12)],
      ),
      body: q.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_recent.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(child: Text('Recent searches', style: AppText.title(size: 15))),
                      TextButton(
                        onPressed: () {
                          LocalStorage.write(LocalStorage.recentSearches, <String>[]);
                          setState(() => _recent = []);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  for (final r in _recent)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history_rounded, color: AppColors.ash),
                      title: Text(r),
                      trailing: const Icon(Icons.north_west_rounded, size: 18, color: AppColors.mist),
                      onTap: () => _submit(r),
                    ),
                  const SizedBox(height: 12),
                ],
                Text('Popular searches', style: AppText.title(size: 15)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in _popular)
                      ActionChip(
                        avatar: const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.terracotta),
                        label: Text(p),
                        onPressed: () => _submit(p),
                      ),
                  ],
                ),
              ],
            )
          : results.isEmpty
          ? EmptyState(icon: Icons.search_off_rounded, title: 'No results for “$q”', message: 'Check the spelling or try a different word.')
          : ListView.separated(
              itemCount: results.length + 1,
              separatorBuilder: (_, _) => const Divider(indent: 76),
              itemBuilder: (_, i) {
                if (i == results.length) {
                  return ListTile(
                    leading: const Icon(Icons.search_rounded),
                    title: Text(
                      'See all results for “$q”',
                      style: AppText.sans(weight: FontWeight.w700, color: AppColors.terracotta),
                    ),
                    onTap: () => _submit(q),
                  );
                }
                final p = results[i];
                return ListTile(
                  leading: AppImage(p.image, tone: p.tone, width: 48, height: 48, radius: 8),
                  title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${p.lineLabel} · ₹${p.price}'),
                  onTap: () => context.pushReplacement('/product/${p.id}'),
                );
              },
            ),
    );
  }
}
