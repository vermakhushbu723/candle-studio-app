import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../../services/razorpay_service.dart';
import '../../state/cart_provider.dart';
import '../../state/catalog_provider.dart';
import '../../state/repositories.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/order_summary.dart';
import 'order_success_view.dart';

const _payments = [
  ('upi', 'UPI', 'Google Pay, PhonePe, Paytm & more', Icons.qr_code_2_rounded),
  ('card', 'Credit / Debit card', 'Visa, Mastercard, RuPay', Icons.credit_card_rounded),
  ('cod', 'Cash on Delivery', 'Pay when your order arrives', Icons.payments_outlined),
];

/// Checkout: login required → Address → Payment (Razorpay UPI/card or COD) → order placed.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  late final Map<String, dynamic> _saved = LocalStorage.read<Map<String, dynamic>>(LocalStorage.address) ?? {};
  late final _name = TextEditingController(text: _saved['fullName'] as String? ?? ref.read(sessionProvider)?.name);
  late final _phone = TextEditingController(text: _saved['phone'] as String? ?? ref.read(sessionProvider)?.phone);
  late final _email = TextEditingController(text: _saved['email'] as String? ?? ref.read(sessionProvider)?.email);
  late final _address = TextEditingController(text: _saved['line1'] as String?);
  late final _city = TextEditingController(text: _saved['city'] as String?);
  late final _state = TextEditingController(text: _saved['state'] as String?);
  late final _pincode = TextEditingController(text: _saved['pincode'] as String?);
  final _giftNote = TextEditingController();
  final _scroll = ScrollController();

  int _step = 0;
  bool _gift = false;
  String _payment = 'upi';
  bool _placing = false;
  PlacedOrder? _pending; // online payment started but not finished
  Order? _done;

  @override
  void dispose() {
    _scroll.dispose();
    for (final c in [_name, _phone, _email, _address, _city, _state, _pincode, _giftNote]) {
      c.dispose();
    }
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  CheckoutDetails get _details => CheckoutDetails(
    fullName: _name.text.trim(),
    phone: _phone.text.trim(),
    email: _email.text.trim(),
    line1: _address.text.trim(),
    city: _city.text.trim(),
    state: _state.text.trim(),
    pincode: _pincode.text.trim(),
    giftNote: _gift ? _giftNote.text.trim() : null,
  );

  Future<void> _next() async {
    if (_step == 0) {
      FocusScope.of(context).unfocus();
      if (!_form.currentState!.validate()) return;
      final d = _details;
      // Remember the address for the next order (like shopping apps do)
      LocalStorage.write(LocalStorage.address, {
        'fullName': d.fullName,
        'phone': d.phone,
        'email': d.email,
        'line1': d.line1,
        'city': d.city,
        'state': d.state,
        'pincode': d.pincode,
      });
      _goTo(1);
      return;
    }
    setState(() => _placing = true);
    try {
      // Online payment already started for this cart → reopen it instead of creating a second order
      if (_pending != null && _payment != 'cod') {
        await _pay(_pending!);
        return;
      }
      final totals = ref.read(cartTotalsProvider);
      final placed = await ref
          .read(orderRepositoryProvider)
          .create(
            details: _details,
            payment: _payment,
            couponCode: totals.coupon?.code,
            items: [
              for (final l in totals.lines) {'productId': l.product.id, 'quantity': l.item.quantity, 'pack': l.item.pack, 'color': l.item.color, 'fragrance': l.item.fragrance},
            ],
          );
      if (placed.razorpay == null) return _finish(placed.order); // Cash on Delivery
      setState(() => _pending = placed);
      await _pay(placed);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) {
        ref.read(sessionProvider.notifier).signOut();
        context.push('/login?next=/checkout');
      } else {
        showToast(context, e.message, error: true);
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  /// Opens Razorpay, then lets the API verify the payment signature.
  Future<void> _pay(PlacedOrder placed) async {
    try {
      final r = await RazorpayService().pay(placed.razorpay!);
      final order = await ref
          .read(orderRepositoryProvider)
          .verifyPayment(placed.order.id, razorpayOrderId: r.orderId, paymentId: r.paymentId, signature: r.signature);
      _finish(order);
    } on PaymentCancelled {
      if (mounted) showToast(context, 'Payment not completed — your order is saved. Tap “Pay now” to try again.');
    } catch (e) {
      if (mounted) showToast(context, '$e'.replaceFirst('Exception: ', ''), error: true);
    }
  }

  void _finish(Order order) {
    HapticFeedback.mediumImpact();
    ref.read(cartProvider.notifier).clear();
    setState(() {
      _done = order;
      _pending = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final totals = ref.watch(cartTotalsProvider);

    if (_done != null) return OrderSuccessView(order: _done!);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Log in to place your order',
          message: 'Use your mobile number or Google — it takes a few seconds. Your bag is saved.',
          actionLabel: 'Log in',
          onAction: () => context.push('/login?next=/checkout'),
        ),
      );
    }

    if (totals.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(icon: Icons.shopping_bag_outlined, title: 'Your bag is empty', actionLabel: 'Shop candles', onAction: () => context.go('/')),
      );
    }

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_step == 0 ? 'Delivery address' : 'Payment'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: _Progress(step: _step, onTap: (s) => s < _step ? _goTo(s) : null),
          ),
        ),
        bottomNavigationBar: StickyBar(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatPrice(totals.total), style: AppText.sans(size: 19, weight: FontWeight.w800)),
                    Text('${totals.count} item${totals.count == 1 ? '' : 's'} · incl. shipping', style: AppText.muted(size: 11.5)),
                  ],
                ),
              ),
              SizedBox(
                width: 190,
                child: ElevatedButton(
                  onPressed: _placing ? null : _next,
                  child: BusyLabel(
                    busy: _placing,
                    label: _step == 0
                        ? 'CONTINUE'
                        : _pending != null && _payment != 'cod'
                        ? 'PAY NOW'
                        : _payment == 'cod'
                        ? 'PLACE ORDER'
                        : 'PAY ${formatPrice(totals.total)}',
                  ),
                ),
              ),
            ],
          ),
        ),
        body: ListView(controller: _scroll, padding: const EdgeInsets.only(bottom: 16), children: _step == 0 ? _addressStep() : _paymentStep()),
      ),
    );
  }

  List<Widget> _addressStep() {
    String? required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
    return [
      Form(
        key: _form,
        child: Column(
          children: [
            SectionCard(
              title: 'Contact details',
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded)),
                    validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Mobile number', prefixText: '+91 ', prefixIcon: Icon(Icons.phone_outlined), counterText: ''),
                    validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch(v?.trim() ?? '') ? null : 'Enter a 10-digit mobile number',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Email (for order updates)', prefixIcon: Icon(Icons.mail_outline_rounded)),
                    validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v?.trim() ?? '') ? null : 'Enter a valid email',
                  ),
                ],
              ),
            ),
            SectionCard(
              title: 'Delivery address',
              child: Column(
                children: [
                  TextFormField(
                    controller: _pincode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Pincode', prefixIcon: Icon(Icons.pin_drop_outlined), counterText: ''),
                    validator: (v) {
                      final pin = v?.trim() ?? '';
                      if (!RegExp(r'^\d{6}$').hasMatch(pin)) return 'Enter a 6-digit pincode';
                      final ship = ref.read(shippingProvider);
                      return ship.deliveryStates.length == 1 ? ship.deliveryError(ship.deliveryStates.first, pin) : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    maxLines: 2,
                    minLines: 1,
                    decoration: const InputDecoration(labelText: 'House no., building, street, area', prefixIcon: Icon(Icons.home_outlined)),
                    validator: (v) => (v?.trim().length ?? 0) < 5 ? 'Enter your full address' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _city,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: required,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final ship = ref.watch(shippingProvider);
                            if (ship.deliveryStates.isEmpty) {
                              return TextFormField(
                                controller: _state,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(labelText: 'State'),
                                validator: required,
                              );
                            }
                            // We only deliver to these states, so the customer picks one of them
                            final current = ship.deliveryStates.contains(_state.text) ? _state.text : null;
                            if (current == null && ship.deliveryStates.length == 1) _state.text = ship.deliveryStates.first;
                            return DropdownButtonFormField<String>(
                              initialValue: current ?? (ship.deliveryStates.length == 1 ? ship.deliveryStates.first : null),
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'State'),
                              items: [for (final s in ship.deliveryStates) DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))],
                              onChanged: (v) => _state.text = v ?? '',
                              validator: (v) => v == null ? 'Choose your state' : ship.deliveryError(v, _pincode.text.trim()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _gift,
                    onChanged: (v) => setState(() => _gift = v),
                    secondary: const Icon(Icons.card_giftcard_rounded, color: AppColors.terracotta),
                    title: Text('This is a gift', style: AppText.sans(size: 15, weight: FontWeight.w600)),
                    subtitle: const Text('Add a handwritten note — free'),
                  ),
                  if (_gift)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _giftNote,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: const InputDecoration(hintText: 'Your message — we’ll handwrite it on a card'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      const PriceDetails(),
    ];
  }

  List<Widget> _paymentStep() {
    final d = _details;
    return [
      if (_pending != null)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD591)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFD48806)),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Order #${_pending!.order.id} is waiting for payment\n',
                        style: AppText.sans(weight: FontWeight.w700),
                      ),
                      const TextSpan(text: 'Tap “Pay now” to complete it, or choose Cash on Delivery.'),
                    ],
                  ),
                  style: AppText.sans(size: 13),
                ),
              ),
            ],
          ),
        ),
      SectionCard(
        title: 'Deliver to',
        trailing: TextButton(onPressed: () => _goTo(0), child: const Text('CHANGE')),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.terracotta),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${d.fullName} · +91 ${d.phone}', style: AppText.sans(weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${d.line1}, ${d.city}, ${d.state} – ${d.pincode}', style: AppText.muted(size: 13)),
                  if (d.giftNote?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 6),
                    Text('🎁 Gift note: ${d.giftNote}', style: AppText.sans(size: 12.5, color: AppColors.cocoa)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      SectionCard(
        title: 'Payment method',
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: RadioGroup<String>(
          groupValue: _payment,
          onChanged: (v) => setState(() => _payment = v ?? _payment),
          child: Column(
            children: [
              for (final (value, label, note, icon) in _payments)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _payment == value ? AppColors.sand.withValues(alpha: 0.55) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _payment == value ? AppColors.terracotta : AppColors.linen),
                  ),
                  child: RadioListTile<String>(
                    value: value,
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: Icon(icon, color: AppColors.terracotta),
                    title: Text(label, style: AppText.sans(size: 15, weight: FontWeight.w700)),
                    subtitle: Text(note),
                  ),
                ),
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.ash),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Online payments are processed securely by Razorpay.', style: AppText.muted(size: 12))),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      const CouponRow(),
      const PriceDetails(showItems: true),
      const SecureNote(),
    ];
  }
}

/// Address ─── Payment progress under the app bar.
class _Progress extends StatelessWidget {
  const _Progress({required this.step, required this.onTap});
  final int step;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    Widget dot(int i, String label) {
      final active = i <= step;
      return InkWell(
        onTap: () => onTap(i),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: active ? AppColors.terracotta : AppColors.linen,
              child: i < step
                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                  : Text(
                      '${i + 1}',
                      style: AppText.sans(size: 12, weight: FontWeight.w700, color: active ? Colors.white : AppColors.ash),
                    ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppText.sans(size: 13, weight: FontWeight.w700, color: active ? AppColors.charcoal : AppColors.ash),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        children: [
          dot(0, 'Address'),
          Expanded(
            child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 10), color: step > 0 ? AppColors.terracotta : AppColors.linen),
          ),
          dot(1, 'Payment'),
          Expanded(
            child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 10), color: AppColors.linen),
          ),
          dot(2, 'Done'),
        ],
      ),
    );
  }
}
