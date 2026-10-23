import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/content/site_content.dart';
import '../../../data/models/product.dart';
import '../../../state/catalog_provider.dart';
import '../../../widgets/product_card.dart';

bool _inBudget(int price, String? budget) => switch (budget) {
  'budget' => price < 500,
  'mid' => price >= 500 && price <= 1000,
  _ => price > 700,
};

/// Three questions → top 3 candles from both ranges (same scoring as the website).
class ScentQuiz extends ConsumerStatefulWidget {
  const ScentQuiz({super.key});

  @override
  ConsumerState<ScentQuiz> createState() => _ScentQuizState();
}

class _ScentQuizState extends ConsumerState<ScentQuiz> {
  int _step = 0;
  final _answers = <String, String>{};

  bool get _done => _step >= scentQuiz.length;

  List<Product> _results(List<Product> products) {
    final scored =
        products
            .map(
              (p) => (
                p: p,
                score:
                    (p.moods.contains(_answers['for']) ? 2 : 0) +
                    (p.moods.contains(_answers['mood']) ? 2 : 0) +
                    (_inBudget(p.price, _answers['budget']) ? 3 : 0),
              ),
            )
            .toList()
          ..sort((a, b) => b.score != a.score ? b.score - a.score : b.p.rating.compareTo(a.p.rating));
    return scored.take(3).map((r) => r.p).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(catalogProvider).valueOrNull?.products ?? const [];
    final percent = (_step.clamp(0, scentQuiz.length) / scentQuiz.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SCENT FINDER', style: AppText.eyebrow(color: AppColors.caramel)),
        const SizedBox(height: 8),
        Text('Not sure which candle? Let us match you.', style: AppText.serif(size: 26, color: AppColors.cream)),
        const SizedBox(height: 8),
        Text(
          'Three quick questions. We’ll pick from both pearled and handcrafted ranges.',
          style: AppText.sans(size: 14, color: AppColors.cream.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: percent, minHeight: 6, color: AppColors.caramel, backgroundColor: Colors.white12),
              ),
            ),
            const SizedBox(width: 10),
            Text('${(percent * 100).round()}%', style: AppText.sans(size: 12, color: AppColors.cream.withValues(alpha: 0.7))),
          ],
        ),
        if (_step > 0)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: OutlinedButton.icon(
              onPressed: () => setState(() {
                _step = 0;
                _answers.clear();
              }),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cream,
                side: const BorderSide(color: Colors.white38),
                minimumSize: const Size(0, 38),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Start over'),
            ),
          ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: !_done
              ? Column(
                  key: ValueKey(_step),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Question ${_step + 1} of ${scentQuiz.length}', style: AppText.sans(size: 13, color: AppColors.cream.withValues(alpha: 0.6))),
                    const SizedBox(height: 6),
                    Text(scentQuiz[_step].question, style: AppText.serif(size: 22, color: AppColors.cream)),
                    const SizedBox(height: 14),
                    for (final o in scentQuiz[_step].options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.white24),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => setState(() {
                              _answers[scentQuiz[_step].id] = o.value;
                              _step++;
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      o.label,
                                      style: AppText.sans(size: 15, weight: FontWeight.w600, color: AppColors.cream),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.caramel),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  key: const ValueKey('results'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your perfect matches', style: AppText.serif(size: 22, color: AppColors.cream)),
                    const SizedBox(height: 14),
                    ProductCarousel(products: _results(products), cardWidth: 160, padding: EdgeInsets.zero),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Home section (dark card).
class ScentFinderSection extends StatelessWidget {
  const ScentFinderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const RadialGradient(center: Alignment.topRight, radius: 1.4, colors: [Color(0xFF6C2A12), AppColors.charcoal]),
        ),
        child: const ScentQuiz(),
      ),
    );
  }
}

/// Full-screen quiz (from the menu and the chatbot).
class ScentFinderScreen extends StatelessWidget {
  const ScentFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.cream,
        title: Text('Scent finder', style: AppText.serif(size: 22, color: AppColors.cream)),
      ),
      body: const SingleChildScrollView(padding: EdgeInsets.all(16), child: ScentQuiz()),
    );
  }
}
