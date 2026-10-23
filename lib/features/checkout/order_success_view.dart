import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models/order.dart';
import '../../widgets/app_image.dart';
import '../../widgets/common.dart';
import '../account/notification_settings.dart';

/// Order placed — confirmation with the order summary.
class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final trackRoute = '/track-order?order=${order.id}&contact=${Uri.encodeComponent(order.trackingContact)}';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Order placed'),
          actions: [IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.go('/'))],
        ),
        bottomNavigationBar: StickyBar(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => context.go('/'), child: const Text('CONTINUE SHOPPING')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(onPressed: () => context.pushReplacement(trackRoute), child: const Text('TRACK ORDER')),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.4, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) => Transform.scale(scale: v, child: child),
                    child: const CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFF168A4C),
                      child: Icon(Icons.check_rounded, size: 52, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Your glow is on its way!',
                    textAlign: TextAlign.center,
                    style: AppText.sans(size: 21, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Order #${order.id} is confirmed. We’ll send updates by email${order.customerPhone.isEmpty ? '' : ' and on WhatsApp'}.',
                    textAlign: TextAlign.center,
                    style: AppText.muted(size: 14),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      order.paymentMethod == 'cod'
                          ? 'Cash on Delivery · pay ${formatPrice(order.total)} on delivery'
                          : 'Paid ${formatPrice(order.total)} online',
                      style: AppText.sans(size: 12.5, weight: FontWeight.w700, color: AppColors.cocoa),
                    ),
                  ),
                ],
              ),
            ),
            SectionCard(
              title: 'Items (${order.itemCount})',
              child: Column(
                children: [
                  for (final i in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          AppImage(i.image, width: 48, height: 48, radius: 8),
                          const SizedBox(width: 12),
                          Expanded(child: Text('${i.name} × ${i.quantity}', style: AppText.sans(size: 13.5))),
                          Text(formatPrice(i.price * i.quantity), style: AppText.sans(weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  const Divider(height: 22),
                  if (order.discount > 0)
                    SummaryRow('Discount${order.couponCode == null ? '' : ' (${order.couponCode})'}', '− ${formatPrice(order.discount)}', accent: true),
                  SummaryRow('Shipping', order.shipping == 0 ? 'FREE' : formatPrice(order.shipping)),
                  SummaryRow('Total', formatPrice(order.total), bold: true),
                ],
              ),
            ),
            SectionCard(
              title: 'Delivering to',
              child: Text('${order.customerName}\n${order.address}', style: AppText.sans(size: 13.5, height: 1.5)),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 0), child: NotificationSettings(compact: true)),
          ],
        ),
      ),
    );
  }
}
