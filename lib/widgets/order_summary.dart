import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import '../state/cart_provider.dart';
import '../state/offer_provider.dart';
import '../state/repositories.dart';
import 'common.dart';

/// Validates a code with the API and applies it to the cart. Returns true on success.
Future<bool> applyCouponCode(BuildContext context, WidgetRef ref, String raw) async {
  final code = raw.trim().toUpperCase();
  if (code.isEmpty) return false;
  try {
    final r = await ref.read(orderRepositoryProvider).validateCoupon(code, ref.read(cartTotalsProvider).subtotal);
    ref.read(cartProvider.notifier).applyCoupon(r.coupon);
    if (context.mounted) showToast(context, r.message);
    return true;
  } on ApiException catch (e) {
    if (context.mounted) showToast(context, e.message, error: true);
    return false;
  }
}

/// "Apply coupon" row → opens the coupons sheet. Shows the applied code with a remove button.
class CouponRow extends ConsumerWidget {
  const CouponRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupon = ref.watch(cartTotalsProvider).coupon;
    final discount = ref.watch(cartTotalsProvider).discount;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: const Icon(Icons.local_offer_outlined),
        title: Text(coupon == null ? 'Apply coupon' : '${coupon.code} applied', style: AppText.sans(size: 15, weight: FontWeight.w700)),
        subtitle: Text(coupon == null ? 'Save more with GLOW10 or your Follow & Save code' : 'You save ${formatPrice(discount)} on this order'),
        trailing: coupon == null
            ? const Icon(Icons.chevron_right_rounded, color: AppColors.mist)
            : TextButton(onPressed: () => ref.read(cartProvider.notifier).removeCoupon(), child: const Text('REMOVE')),
        onTap: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const CouponSheet()),
      ),
    );
  }
}

/// Enter a code or pick one: GLOW10, the customer's Follow & Save coupon, or how to unlock it.
class CouponSheet extends ConsumerStatefulWidget {
  const CouponSheet({super.key});

  @override
  ConsumerState<CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends ConsumerState<CouponSheet> {
  final _code = TextEditingController();
  String? _busy;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _apply(String code) async {
    setState(() => _busy = code);
    final ok = await applyCouponCode(context, ref, code);
    if (!mounted) return;
    setState(() => _busy = null);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final offer = ref.watch(followOfferProvider).valueOrNull;
    final personal = offer?.coupon;

    Widget couponTile({required String code, required String title, required String subtitle, VoidCallback? onTap, String action = 'APPLY'}) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.linen),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.sand,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.caramel),
          ),
          child: Text(
            code,
            style: AppText.sans(size: 12, weight: FontWeight.w800, color: AppColors.terracotta),
          ),
        ),
        title: Text(title, style: AppText.sans(size: 14, weight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: TextButton(
          onPressed: _busy == null ? onTap : null,
          child: _busy == code ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(action),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHeader('Coupons & offers'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _code,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]'))],
                      onSubmitted: _apply,
                      decoration: const InputDecoration(hintText: 'Enter coupon code', prefixIcon: Icon(Icons.confirmation_number_outlined)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(onPressed: _busy == null ? () => _apply(_code.text) : null, child: const Text('Apply')),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('AVAILABLE FOR YOU', style: AppText.eyebrow(color: AppColors.ash)),
              const SizedBox(height: 10),
              if (personal != null && personal.usable)
                couponTile(
                  code: personal.code,
                  title: '${personal.percent}% off · Follow & Save',
                  subtitle: 'Your personal coupon${personal.expiry == null ? '' : ' · valid till ${formatDate(personal.expiry)}'}',
                  onTap: () => _apply(personal.code),
                ),
              couponTile(code: 'GLOW10', title: '10% off your first order', subtitle: 'For new customers', onTap: () => _apply('GLOW10')),
              if (offer != null && offer.enabled && personal == null)
                couponTile(
                  code: 'FOLLOW',
                  title: 'Get ${offer.percent}% off — follow us',
                  subtitle: 'Follow Jyotessa on Instagram, Facebook & Google to unlock',
                  action: 'UNLOCK',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/follow');
                  },
                ),
              Text('Only one coupon can be used per order.', style: AppText.muted(size: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Price details block (cart, checkout).
class PriceDetails extends ConsumerWidget {
  const PriceDetails({super.key, this.showItems = false});
  final bool showItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(cartTotalsProvider);
    final mrpSavings = t.lines.fold(0, (s, l) => s + ((l.product.compareAt ?? l.product.price) - l.product.price).clamp(0, 1 << 30) * l.item.quantity);
    final saved = mrpSavings + t.discount;
    return SectionCard(
      title: 'Price details (${t.count} item${t.count == 1 ? '' : 's'})',
      child: Column(
        children: [
          if (showItems)
            for (final l in t.lines) SummaryRow('${l.product.name} × ${l.item.quantity}', formatPrice(l.lineTotal)),
          if (showItems) const Divider(height: 18),
          SummaryRow('Subtotal', formatPrice(t.subtotal)),
          if (t.discount > 0) SummaryRow('Coupon (${t.coupon?.code})', '− ${formatPrice(t.discount)}', accent: true),
          SummaryRow('Shipping', t.shipping == 0 ? 'FREE' : formatPrice(t.shipping), accent: t.shipping == 0),
          const Divider(height: 22),
          SummaryRow('Total amount', formatPrice(t.total), bold: true),
          if (saved > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: const Color(0xFFE9F7EF), borderRadius: BorderRadius.circular(10)),
              child: Text(
                'You save ${formatPrice(saved)} on this order 🎉',
                style: AppText.sans(size: 13, weight: FontWeight.w700, color: const Color(0xFF168A4C)),
              ),
            ),
          if (t.remainingForFree != null && t.remainingForFree! > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 17, color: AppColors.terracotta),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add ${formatPrice(t.remainingForFree!)} more for FREE shipping',
                      style: AppText.sans(size: 12.5, weight: FontWeight.w600, color: AppColors.cocoa),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Small "safe & secure" note under price details.
class SecureNote extends StatelessWidget {
  const SecureNote({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.ash),
        const SizedBox(width: 6),
        Text('Safe & secure payments · Easy 7-day returns', style: AppText.muted(size: 12)),
      ],
    ),
  );
}
