import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/repositories/offer_repository.dart';
import '../../services/device_identity.dart';
import '../../services/launcher.dart';
import '../../state/offer_provider.dart';
import '../../state/repositories.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/order_summary.dart';

IconData _iconFor(String key) => switch (key) {
  'instagram' => Icons.camera_alt_outlined,
  'facebook' => Icons.facebook_rounded,
  'google' => Icons.star_rounded,
  'youtube' => Icons.play_circle_outline_rounded,
  _ => Icons.link_rounded,
};

Color _colorFor(String key) => switch (key) {
  'instagram' => const Color(0xFFDD2A7B),
  'facebook' => const Color(0xFF1877F2),
  'google' => const Color(0xFF4285F4),
  'youtube' => const Color(0xFFFF0000),
  _ => AppColors.terracotta,
};

/// Follow & Save — follow our pages and share the username; the team checks it and switches on a personal one-time coupon.
class FollowOfferScreen extends ConsumerStatefulWidget {
  const FollowOfferScreen({super.key});

  @override
  ConsumerState<FollowOfferScreen> createState() => _FollowOfferScreenState();
}

class _FollowOfferScreenState extends ConsumerState<FollowOfferScreen> {
  List<String> _visited = (LocalStorage.read<List<dynamic>>(LocalStorage.followVisited) ?? []).map((e) => '$e').toList();
  bool _deviceUsed = false;
  bool _claiming = false;
  final _handle = TextEditingController();

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ref
        .read(offerRepositoryProvider)
        .deviceUsed(DeviceIdentity.deviceId())
        .then((v) {
          if (mounted) setState(() => _deviceUsed = v);
        })
        .catchError((_) {});
  }

  Future<void> _open(FollowLink l) async {
    await Launcher.open(l.url);
    if (_visited.contains(l.key)) return;
    setState(() => _visited = [..._visited, l.key]);
    LocalStorage.write(LocalStorage.followVisited, _visited);
  }

  Future<void> _claim() async {
    setState(() => _claiming = true);
    try {
      final message = await ref
          .read(offerRepositoryProvider)
          .claim(deviceId: DeviceIdentity.deviceId(), fingerprint: await DeviceIdentity.fingerprint(), visited: _visited, handle: _handle.text.trim());
      HapticFeedback.mediumImpact();
      ref.invalidate(followOfferProvider);
      if (mounted) showToast(context, message);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) {
        context.push('/login?next=/follow');
      } else {
        showToast(context, e.message, error: true);
        if (e.status == 409) setState(() => _deviceUsed = true);
        ref.invalidate(followOfferProvider);
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final async = ref.watch(followOfferProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Follow & Save')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetry(message: '$e', onRetry: () => ref.invalidate(followOfferProvider)),
        data: (offer) {
          final allVisited = offer.links.isNotEmpty && offer.links.every((l) => _visited.contains(l.key));
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // Hero
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6C2A12), AppColors.charcoal]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SCAN · FOLLOW · SAVE', style: AppText.eyebrow(color: AppColors.caramel)),
                    const SizedBox(height: 8),
                    Text('Follow us & get ${offer.percent}% off', style: AppText.serif(size: 26, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                      'Follow Jyotessa on our social pages and unlock a personal ${offer.percent}% coupon for your next order.',
                      style: AppText.sans(size: 13.5, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              if (offer.coupon != null)
                _CouponCard(coupon: offer.coupon!)
              else if (offer.pending)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: EmptyState(
                    icon: Icons.hourglass_top_rounded,
                    title: 'We’re checking your follow',
                    message:
                        'Thanks${offer.handle == null ? '' : ', @${offer.handle}'}! Our team will check that you follow Jyotessa and switch on your ${offer.percent}% coupon — usually within 24 hours. It will appear right here.',
                    actionLabel: 'CHECK AGAIN',
                    onAction: () => ref.invalidate(followOfferProvider),
                  ),
                )
              else if (!offer.enabled)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: EmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'This offer has ended',
                    message: 'Follow our pages to hear about the next one first.',
                  ),
                )
              else if (user != null && _deviceUsed)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: EmptyState(
                    icon: Icons.phonelink_lock_outlined,
                    title: 'Already claimed on this phone',
                    message: 'The Follow & Save coupon can be claimed once per device. Log in with the account that claimed it to see the code.',
                  ),
                )
              else ...[
                _Step(
                  n: 1,
                  done: user != null,
                  title: 'Log in or sign up',
                  text: user == null ? 'Your coupon is personal — it’s saved to your account.' : 'Logged in as ${user.name}',
                  action: user == null ? ElevatedButton(onPressed: () => context.push('/login?next=/follow'), child: const Text('LOG IN')) : null,
                ),
                _Step(
                  n: 2,
                  done: allVisited,
                  title: 'Follow us on every page',
                  text: 'Tap each one, follow (and leave a review on Google), then come back.',
                  action: Column(
                    children: [
                      for (final l in offer.links)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            color: _visited.contains(l.key) ? const Color(0xFFE9F7EF) : Colors.white,
                            borderColor: _visited.contains(l.key) ? const Color(0xFF9AD8B4) : AppColors.linen,
                            onTap: () => _open(l),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: _colorFor(l.key),
                                  child: Icon(_iconFor(l.key), color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l.key == 'google' ? 'Follow & review on Google' : 'Follow on ${l.label}',
                                    style: AppText.sans(size: 14, weight: FontWeight.w700),
                                  ),
                                ),
                                _visited.contains(l.key)
                                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF168A4C))
                                    : const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.ash),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _Step(
                  n: 3,
                  done: false,
                  title: 'Claim your ${offer.percent}% coupon',
                  text: allVisited
                      ? 'Tell us the username you followed from. We check it and switch on your code — usually within 24 hours.'
                      : 'Follow all ${offer.links.length} pages above to continue.',
                  action: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _handle,
                        enabled: allVisited,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(labelText: 'Your Instagram / Facebook username', prefixText: '@ '),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: user != null && allVisited && _handle.text.trim().length >= 2 && !_claiming ? _claim : null,
                        icon: const Icon(Icons.card_giftcard_rounded),
                        label: BusyLabel(busy: _claiming, label: 'REQUEST MY ${offer.percent}% COUPON'),
                      ),
                    ],
                  ),
                ),
              ],
              SectionCard(
                title: 'Offer conditions',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final r in [
                      '${offer.percent}% off your order subtotal${offer.maxDiscount > 0 ? ' (up to ${formatPrice(offer.maxDiscount)})' : ''}.',
                      'One coupon per customer account and one per phone.',
                      'Personal — works only when you’re logged in to the account that claimed it.',
                      'We check every follow before the coupon is switched on — unfollowing later may cancel it.',
                      'Single use. Valid for ${offer.validDays} days after it is switched on.',
                      'Only one coupon per order. Misuse (multiple accounts, fake numbers) may cancel the coupon.',
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 7, right: 10),
                              child: CircleAvatar(radius: 2.5, backgroundColor: AppColors.terracotta),
                            ),
                            Expanded(
                              child: Text(r, style: AppText.sans(size: 13, color: AppColors.ash)),
                            ),
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

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.done, required this.title, required this.text, this.action});
  final int n;
  final bool done;
  final String title;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: done ? const Color(0xFF168A4C) : AppColors.terracotta,
            child: done
                ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                : Text(
                    '$n',
                    style: AppText.sans(size: 13, weight: FontWeight.w800, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: AppText.sans(size: 15.5, weight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(text, style: AppText.muted(size: 12.5)),
                if (action != null) ...[const SizedBox(height: 12), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends ConsumerWidget {
  const _CouponCard({required this.coupon});
  final PersonalCoupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.caramel),
      ),
      child: Column(
        children: [
          Text('YOUR ${coupon.percent}% OFF COUPON', style: AppText.eyebrow()),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.sand,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.caramel, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  coupon.code,
                  style: AppText.sans(size: 22, weight: FontWeight.w800, color: AppColors.terracotta).copyWith(letterSpacing: 2.5),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: AppColors.terracotta),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: coupon.code));
                    showToast(context, 'Coupon code copied');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            coupon.used
                ? 'Already used — thank you for shopping with us!'
                : coupon.expired
                ? 'This coupon expired on ${formatDate(coupon.expiry)}.'
                : 'Valid till ${formatDate(coupon.expiry)} · one-time use · only on your account',
            textAlign: TextAlign.center,
            style: AppText.muted(size: 12.5),
          ),
          if (coupon.usable) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await applyCouponCode(context, ref, coupon.code);
                  if (context.mounted) context.go('/');
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('APPLY & SHOP NOW'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
