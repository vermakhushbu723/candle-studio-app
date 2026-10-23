import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content/site_content.dart';
import '../../state/catalog_provider.dart';
import '../../widgets/common.dart';

/// Help centre — FAQs in tabs, with search.
class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final shipping = ref.watch(shippingProvider);
    final q = _q.toLowerCase();
    List<Faq> filter(List<Faq> items) => items.where((f) => '${f.q} ${f.a}'.toLowerCase().contains(q)).toList();

    Widget list(List<Faq> items) => items.isEmpty
        ? EmptyState(icon: Icons.search_off_rounded, title: 'No questions match “$_q”', message: 'Try another word or chat with us.')
        : ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              if (i == items.length) return const _StillNeedHelp();
              final f = items[i];
              return Container(
                color: Colors.white,
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  iconColor: AppColors.terracotta,
                  collapsedIconColor: AppColors.ash,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedAlignment: Alignment.centerLeft,
                  title: Text(f.q, style: AppText.sans(size: 14.5, weight: FontWeight.w600)),
                  children: [Text(shipping.fill(f.a), style: AppText.sans(size: 13.5, color: AppColors.ash, height: 1.6))],
                ),
              );
            },
          );

    return DefaultTabController(
      length: faqs.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Help centre'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(112),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: TextField(
                      onChanged: (v) => setState(() => _q = v),
                      decoration: InputDecoration(
                        hintText: 'Search your question…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        isDense: true,
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      const Tab(text: 'All'),
                      for (final g in faqs) Tab(text: g.group),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(children: [list(filter(faqs.expand((g) => g.items).toList())), for (final g in faqs) list(filter(g.items))]),
      ),
    );
  }
}

class _StillNeedHelp extends StatelessWidget {
  const _StillNeedHelp();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
    child: AppCard(
      color: AppColors.sand,
      child: Column(
        children: [
          Text('Still need help?', style: AppText.title(size: 16)),
          const SizedBox(height: 4),
          Text('Our team replies within 24 hours.', style: AppText.muted()),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => context.push('/contact'), child: const Text('CONTACT US')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(onPressed: () => context.push('/chat'), child: const Text('CHAT NOW')),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
