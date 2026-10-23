import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/push_service.dart';
import '../../state/repositories.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';

/// Push on this phone + "New arrivals & offers" preference (GET/PUT /notifications/preferences).
class NotificationSettings extends ConsumerStatefulWidget {
  const NotificationSettings({super.key, this.compact = false});

  /// Compact = just the "Turn on notifications" button (order confirmation screen).
  final bool compact;

  @override
  ConsumerState<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends ConsumerState<NotificationSettings> {
  PushStatus _status = PushStatus.unsupported;
  bool? _offers;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    PushService.instance.status().then((s) {
      if (mounted) setState(() => _status = s);
    });
    if (!widget.compact && ref.read(sessionProvider) != null) {
      ref
          .read(supportRepositoryProvider)
          .offersEnabled()
          .then((v) {
            if (mounted) setState(() => _offers = v);
          })
          .catchError((_) {});
    }
  }

  Future<void> _turnOn() async {
    setState(() => _busy = true);
    final s = await PushService.instance.enable(loggedIn: ref.read(sessionProvider) != null);
    if (!mounted) return;
    setState(() {
      _status = s;
      _busy = false;
    });
    showToast(
      context,
      s == PushStatus.granted ? 'Notifications are on for this phone' : 'Notifications are blocked. Allow them in Settings → Apps → Jyotessa → Notifications.',
      error: s != PushStatus.granted,
    );
  }

  Future<void> _toggleOffers(bool v) async {
    setState(() => _offers = v);
    try {
      await ref.read(supportRepositoryProvider).setOffers(v);
      if (mounted) showToast(context, v ? 'You’ll hear about new arrivals and offers' : 'Offer updates turned off — you’ll still get order updates');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _offers = !v);
      showToast(context, e.message, error: true);
    }
  }

  Widget? _pushRow() => switch (_status) {
    PushStatus.granted => Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
        const SizedBox(width: 8),
        Text(
          'Notifications are on for this phone',
          style: AppText.sans(size: 13, color: AppColors.success, weight: FontWeight.w600),
        ),
      ],
    ),
    PushStatus.notAsked =>
      widget.compact
          ? ElevatedButton.icon(
              onPressed: _busy ? null : _turnOn,
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Turn on notifications'),
            )
          : OutlinedButton.icon(
              onPressed: _busy ? null : _turnOn,
              icon: const Icon(Icons.notifications_none_rounded),
              label: const Text('Turn on notifications'),
            ),
    PushStatus.denied => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notifications are blocked for this app. Allow them from Settings → Apps → Jyotessa → Notifications.', style: AppText.muted()),
        TextButton(onPressed: _turnOn, child: const Text('Try again')),
      ],
    ),
    PushStatus.unsupported => null,
  };

  @override
  Widget build(BuildContext context) {
    final row = _pushRow();
    if (widget.compact) return _status == PushStatus.notAsked ? row! : const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NOTIFICATIONS', style: AppText.eyebrow()),
          const SizedBox(height: 8),
          Text('Order updates (confirmed, shipped, delivered) come by email and on this phone.', style: AppText.muted()),
          if (row != null) ...[const SizedBox(height: 12), row],
          if (_offers != null) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _offers!,
              onChanged: _toggleOffers,
              title: Text('New arrivals & offers', style: AppText.sans(weight: FontWeight.w600)),
              subtitle: Text('Launches, festive collections and coupon codes', style: AppText.muted(size: 12)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Notifications settings screen (Account → Notifications).
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const NotificationSettings(),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What we send', style: AppText.title(size: 15)),
                const SizedBox(height: 10),
                for (final (icon, title, text) in [
                  (Icons.check_circle_outline_rounded, 'Order confirmed', 'As soon as your order or payment goes through'),
                  (Icons.local_shipping_outlined, 'Shipped & out for delivery', 'With the courier and tracking number'),
                  (Icons.star_border_rounded, 'Delivered', 'Plus a quick link to rate us'),
                  (Icons.local_offer_outlined, 'Offers & new arrivals', 'Only if you keep offers switched on'),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(icon, color: AppColors.terracotta, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppText.sans(size: 14, weight: FontWeight.w700)),
                              Text(text, style: AppText.muted(size: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (user == null) ...[
            const SizedBox(height: 16),
            AppCard(
              color: AppColors.sand,
              onTap: () => context.push('/login'),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.terracotta),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Log in to get order updates and manage offer alerts', style: AppText.sans(size: 13.5, weight: FontWeight.w600)),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
