import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content/site_content.dart';
import '../../state/catalog_provider.dart';
import '../../widgets/common.dart';
import 'not_found_screen.dart';

const _policyIcons = {
  'shipping': Icons.local_shipping_outlined,
  'returns': Icons.assignment_return_outlined,
  'privacy': Icons.privacy_tip_outlined,
  'terms': Icons.gavel_outlined,
  'disclaimer': Icons.report_gmailerrorred_outlined,
};

/// Policies & terms hub (Account → Policies & terms).
class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Policies & terms')),
      body: ListView(
        children: [
          MenuGroup(
            children: [
              for (final e in policies.entries)
                MenuTile(
                  icon: _policyIcons[e.key] ?? Icons.description_outlined,
                  title: e.value.title,
                  onTap: () => context.push(e.key == 'disclaimer' ? '/disclaimer' : '/policies/${e.key}'),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Questions? Write to ${Site.supportEmail} or call ${Site.phone}.', textAlign: TextAlign.center, style: AppText.muted(size: 12.5)),
          ),
        ],
      ),
    );
  }
}

/// One policy: Shipping, Returns, Privacy, Terms or Disclaimer. {shipping} uses the admin's settings.
class PolicyScreen extends ConsumerWidget {
  const PolicyScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policy = policies[id];
    if (policy == null) return const NotFoundScreen();
    final shipping = ref.watch(shippingProvider);
    final isDisclaimer = id == 'disclaimer';

    return Scaffold(
      appBar: AppBar(title: Text(policy.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.sand,
                  child: Icon(_policyIcons[id] ?? Icons.description_outlined, color: AppColors.terracotta),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(policy.title, style: AppText.sans(size: 16, weight: FontWeight.w800)),
                      Text(isDisclaimer ? 'Last updated: 1 August 2026' : 'Jyotessa · ${Site.supportEmail}', style: AppText.muted(size: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isDisclaimer)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'The information in this app is provided by Jyotessa in good faith. By using it or buying our products, you agree to the disclaimers below.',
                style: AppText.muted(size: 12.5),
              ),
            ),
          for (var i = 0; i < policy.sections.length; i++)
            SectionCard(
              title: '${i + 1}. ${policy.sections[i].heading}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (policy.sections[i].text != null)
                    Text(shipping.fill(policy.sections[i].text!), style: AppText.sans(size: 13.5, color: AppColors.ash, height: 1.6)),
                  for (final b in policy.sections[i].bullets ?? const <String>[])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 7, right: 10),
                            child: CircleAvatar(radius: 2.5, backgroundColor: AppColors.terracotta),
                          ),
                          Expanded(
                            child: Text(b, style: AppText.sans(size: 13.5, color: AppColors.ash, height: 1.55)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          MenuGroup(
            title: 'Other policies',
            children: [
              for (final e in policies.entries.where((e) => e.key != id))
                MenuTile(
                  icon: _policyIcons[e.key] ?? Icons.description_outlined,
                  title: e.value.title,
                  onTap: () => context.pushReplacement(e.key == 'disclaimer' ? '/disclaimer' : '/policies/${e.key}'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
