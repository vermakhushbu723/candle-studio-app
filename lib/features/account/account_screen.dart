import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content/site_content.dart';
import '../../data/models/order.dart';
import '../../services/google_auth_service.dart';
import '../../services/launcher.dart';
import '../../services/push_service.dart';
import '../../state/offer_provider.dart';
import '../../state/repositories.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';
import '../orders/order_tile.dart';
import 'user_avatar.dart';

/// Orders of the logged-in customer (GET /orders/mine).
final myOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  if (ref.watch(sessionProvider) == null) return Future.value([]);
  return ref.read(orderRepositoryProvider).myOrders();
});

/// Logs out on this phone: unlinks push, signs out of Google, clears the session.
Future<void> logout(WidgetRef ref) async {
  await PushService.instance.unlinkDevice();
  await GoogleAuthService().signOut();
  ref.read(sessionProvider.notifier).signOut();
}

/// Account tab — profile, orders, offers, help and settings.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log in again anytime with your mobile number or Google.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('LOG OUT')),
        ],
      ),
    );
    if (ok != true) return;
    await logout(ref);
    if (context.mounted) showToast(context, 'You have been logged out.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final offer = ref.watch(followOfferProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [IconButton(icon: const Icon(Icons.notifications_none_rounded), tooltip: 'Notifications', onPressed: () => context.push('/notifications'))],
      ),
      body: RefreshIndicator(
        color: AppColors.terracotta,
        onRefresh: () async {
          await ref.read(sessionProvider.notifier).refresh();
          ref.invalidate(myOrdersProvider);
          ref.invalidate(followOfferProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Profile header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6C2A12), AppColors.charcoal]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: user == null
                  ? Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white12,
                          child: Icon(Icons.person_outline_rounded, color: AppColors.caramel, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to Jyotessa',
                                style: AppText.sans(size: 16, weight: FontWeight.w800, color: Colors.white),
                              ),
                              Text('Log in to track orders & check out faster', style: AppText.sans(size: 12.5, color: Colors.white70)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.caramel,
                            foregroundColor: AppColors.charcoal,
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text('LOG IN'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: AppColors.caramel, shape: BoxShape.circle),
                          child: UserAvatar(user: user, size: 56),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.sans(size: 17, weight: FontWeight.w800, color: Colors.white),
                              ),
                              Text(user.contactLabel, style: AppText.sans(size: 12.5, color: Colors.white70)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit profile',
                          onPressed: () => context.push('/profile'),
                          icon: const Icon(Icons.edit_outlined, color: AppColors.caramel),
                        ),
                      ],
                    ),
            ),
            // Quick actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  for (final (icon, label, onTap) in [
                    (Icons.receipt_long_outlined, 'Orders', () => context.push(user == null ? '/login' : '/orders')),
                    (Icons.favorite_border_rounded, 'Wishlist', () => context.go('/wishlist')),
                    (Icons.local_offer_outlined, 'Coupons', () => context.push('/follow')),
                    (Icons.support_agent_rounded, 'Help', () => context.push('/chat')),
                  ])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          onTap: onTap,
                          child: Column(
                            children: [
                              Icon(icon, color: AppColors.terracotta),
                              const SizedBox(height: 6),
                              Text(label, style: AppText.sans(size: 12, weight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Follow & Save
            if (offer != null && offer.enabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: AppCard(
                  color: AppColors.sand,
                  onTap: () => context.push('/follow'),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard_rounded, color: AppColors.terracotta),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          offer.coupon != null
                              ? 'Your ${offer.coupon!.percent}% coupon: ${offer.coupon!.code}${offer.coupon!.usable ? '' : (offer.coupon!.used ? ' (used)' : ' (expired)')}'
                              : 'Follow us & get ${offer.percent}% off your next order',
                          style: AppText.sans(size: 13.5, weight: FontWeight.w700, color: AppColors.cocoa),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.cocoa),
                    ],
                  ),
                ),
              ),
            if (user != null) const _RecentOrders(),
            MenuGroup(
              title: 'My activity',
              children: [
                MenuTile(icon: Icons.receipt_long_outlined, title: 'My orders', onTap: () => context.push(user == null ? '/login' : '/orders')),
                MenuTile(icon: Icons.local_shipping_outlined, title: 'Track an order', onTap: () => context.push('/track-order')),
                MenuTile(icon: Icons.favorite_border_rounded, title: 'Wishlist', onTap: () => context.go('/wishlist')),
                MenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Order updates & offers',
                  onTap: () => context.push('/notifications'),
                ),
                if (user != null) MenuTile(icon: Icons.person_outline_rounded, title: 'Edit profile', onTap: () => context.push('/profile')),
              ],
            ),
            MenuGroup(
              title: 'Shop',
              children: [
                MenuTile(icon: Icons.storefront_outlined, title: 'All candles', onTap: () => context.push('/shop')),
                MenuTile(icon: Icons.style_outlined, title: 'All collections', onTap: () => context.push('/collections')),
                MenuTile(icon: Icons.auto_awesome_outlined, title: 'Scent finder quiz', onTap: () => context.push('/scent-finder')),
                MenuTile(icon: Icons.business_center_outlined, title: 'Bulk & corporate gifting', onTap: () => context.push('/contact?topic=bulk')),
              ],
            ),
            MenuGroup(
              title: 'Help & support',
              children: [
                MenuTile(icon: Icons.support_agent_rounded, title: 'Chat with Diya', subtitle: 'Instant answers, 24×7', onTap: () => context.push('/chat')),
                MenuTile(icon: Icons.chat_outlined, title: 'WhatsApp us', subtitle: Site.whatsapp, onTap: Launcher.whatsapp),
                MenuTile(icon: Icons.call_outlined, title: 'Call us', subtitle: Site.phone, onTap: Launcher.call),
                MenuTile(icon: Icons.mail_outline_rounded, title: 'Contact us', onTap: () => context.push('/contact')),
                MenuTile(icon: Icons.help_outline_rounded, title: 'FAQs', onTap: () => context.push('/faq')),
              ],
            ),
            MenuGroup(
              title: 'About',
              children: [
                MenuTile(icon: Icons.info_outline_rounded, title: 'About Jyotessa', onTap: () => context.push('/about')),
                MenuTile(icon: Icons.star_border_rounded, title: 'Rate us on Google', onTap: Launcher.review),
                MenuTile(icon: Icons.camera_alt_outlined, title: 'Follow on Instagram', onTap: () => Launcher.open(Site.instagram)),
                MenuTile(icon: Icons.policy_outlined, title: 'Policies & terms', onTap: () => context.push('/policies')),
              ],
            ),
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  color: Colors.white,
                  child: MenuTile(icon: Icons.logout_rounded, title: 'Log out', color: AppColors.danger, onTap: () => _confirmLogout(context, ref)),
                ),
              ),
            const SizedBox(height: 18),
            Center(child: Text('Jyotessa · v1.0.0 · Made in India', style: AppText.muted(size: 11))),
          ],
        ),
      ),
    );
  }
}

class _RecentOrders extends ConsumerWidget {
  const _RecentOrders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider).valueOrNull ?? const [];
    if (orders.isEmpty) return const SizedBox.shrink();
    final latest = orders.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Latest order', action: 'All orders', onAction: () => context.push('/orders')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: OrderTile(order: latest),
          ),
        ),
      ],
    );
  }
}
