import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../data/models/order.dart';
import '../../services/razorpay_service.dart';
import '../../state/repositories.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';
import '../account/account_screen.dart';
import 'order_tile.dart';

/// All orders of the account. Unpaid online orders get a "Pay now" button (POST /orders/:id/retry-payment).
class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  String? _paying;

  Future<void> _payNow(Order order) async {
    setState(() => _paying = order.id);
    final repo = ref.read(orderRepositoryProvider);
    try {
      final placed = await repo.retryPayment(order.id);
      if (placed.razorpay == null) throw ApiException('This order no longer needs a payment.');
      final r = await RazorpayService().pay(placed.razorpay!);
      await repo.verifyPayment(order.id, razorpayOrderId: r.orderId, paymentId: r.paymentId, signature: r.signature);
      if (mounted) showToast(context, 'Payment received — order #${order.id} is confirmed 🎉');
      ref.invalidate(myOrdersProvider);
    } on PaymentCancelled {
      if (mounted) showToast(context, 'Payment not completed.');
    } catch (e) {
      if (mounted) showToast(context, '$e'.replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _paying = null);
    }
  }

  String _filter = 'all';

  bool _matches(Order o) => switch (_filter) {
    'active' => !o.isCancelled && o.status != 'Delivered',
    'delivered' => o.status == 'Delivered',
    'cancelled' => o.isCancelled,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final orders = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: user == null
          ? EmptyState(icon: Icons.lock_outline_rounded, title: 'Log in to see your orders', actionLabel: 'Log in', onAction: () => context.push('/login'))
          : orders.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorRetry(message: '$e', onRetry: () => ref.invalidate(myOrdersProvider)),
              data: (all) {
                if (all.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No orders yet',
                    message: 'Your candles will show up here once you order.',
                    actionLabel: 'Start shopping',
                    onAction: () => context.go('/'),
                  );
                }
                final list = all.where(_matches).toList();
                return RefreshIndicator(
                  color: AppColors.terracotta,
                  onRefresh: () async => ref.invalidate(myOrdersProvider),
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
                              for (final (id, label) in const [('all', 'All'), ('active', 'Active'), ('delivered', 'Delivered'), ('cancelled', 'Cancelled')])
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      '$label (${id == 'all' ? all.length : all.where((o) => switch (id) {
                                              'active' => !o.isCancelled && o.status != 'Delivered',
                                              'delivered' => o.status == 'Delivered',
                                              _ => o.isCancelled,
                                            }).length})',
                                    ),
                                    selected: _filter == id,
                                    showCheckmark: false,
                                    onSelected: (_) => setState(() => _filter = id),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (list.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(icon: Icons.inbox_outlined, title: 'Nothing here'),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.all(12),
                        sliver: SliverList.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final o = list[i];
                            return AppCard(
                              padding: EdgeInsets.zero,
                              child: OrderTile(
                                order: o,
                                trailing: o.isPaymentPending && o.paymentMethod != 'cod'
                                    ? SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: _paying == null ? () => _payNow(o) : null,
                                          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                                          icon: _paying == o.id
                                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                              : const Icon(Icons.lock_outline_rounded, size: 16),
                                          label: Text('PAY ${formatPrice(o.total)} NOW'),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
