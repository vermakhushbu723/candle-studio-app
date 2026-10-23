import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models/order.dart';
import '../../widgets/app_image.dart';

Color statusColor(String status) => switch (status) {
  'Cancelled' => AppColors.danger,
  'Delivered' => const Color(0xFF168A4C),
  'Payment Pending' => const Color(0xFFD48806),
  _ => const Color(0xFF2563EB),
};

IconData statusIcon(String status) => switch (status) {
  'Cancelled' => Icons.cancel_outlined,
  'Delivered' => Icons.check_circle_outline_rounded,
  'Payment Pending' => Icons.hourglass_bottom_rounded,
  'Shipped' || 'Out for Delivery' => Icons.local_shipping_outlined,
  'Packed' => Icons.inventory_2_outlined,
  _ => Icons.receipt_long_outlined,
};

/// One order card → opens tracking.
class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, this.trailing});
  final Order order;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(order.status);
    final first = order.items.isEmpty ? null : order.items.first;
    return InkWell(
      onTap: () => context.push('/track-order?order=${order.id}&contact=${Uri.encodeComponent(order.trackingContact)}'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon(order.status), size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  order.status,
                  style: AppText.sans(size: 13.5, weight: FontWeight.w800, color: color),
                ),
                const Spacer(),
                Text(formatDate(order.date), style: AppText.muted(size: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppImage(first?.image, width: 56, height: 56, radius: 10),
                    if (order.items.length > 1)
                      Positioned(
                        right: -6,
                        bottom: -6,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.charcoal,
                          child: Text(
                            '+${order.items.length - 1}',
                            style: AppText.sans(size: 10, weight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        first?.name ?? 'Order',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(size: 14, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${order.id} · ${order.itemCount} item${order.itemCount == 1 ? '' : 's'} · ${formatPrice(order.total)}',
                        style: AppText.muted(size: 12.5),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.mist),
              ],
            ),
            if (trailing != null) ...[const SizedBox(height: 12), trailing!],
          ],
        ),
      ),
    );
  }
}
