import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models/order.dart';
import '../../services/launcher.dart';
import '../../state/repositories.dart';
import '../../widgets/app_image.dart';
import '../../widgets/common.dart';
import 'order_tile.dart';

const _stageIcons = [
  Icons.receipt_long_outlined,
  Icons.inventory_2_outlined,
  Icons.local_shipping_outlined,
  Icons.delivery_dining_outlined,
  Icons.home_outlined,
];
const _stageTitles = ['Order placed', 'Packed', 'Shipped', 'Out for delivery', 'Delivered'];

/// Order details & tracking (GET /orders/track/:id) — works without login using order ID + phone/email.
class TrackOrderScreen extends ConsumerStatefulWidget {
  const TrackOrderScreen({super.key, this.orderId, this.contact});
  final String? orderId;
  final String? contact;

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  final _form = GlobalKey<FormState>();
  late final _orderId = TextEditingController(text: widget.orderId);
  late final _contact = TextEditingController(text: widget.contact);
  Order? _order;
  String? _error;
  bool _loading = false;

  bool get _direct => (widget.orderId?.isNotEmpty ?? false) && (widget.contact?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    if (_direct) WidgetsBinding.instance.addPostFrameCallback((_) => _track());
  }

  @override
  void dispose() {
    _orderId.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _track() async {
    if (_form.currentState != null && !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final o = await ref.read(orderRepositoryProvider).track(_orderId.text, _contact.text);
      setState(() => _order = o);
    } on ApiException catch (e) {
      setState(() {
        _order = null;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = _order;
    return Scaffold(
      appBar: AppBar(
        title: Text(o != null ? 'Order #${o.id}' : 'Track order'),
        actions: [
          if (o != null)
            IconButton(
              tooltip: 'Copy order ID',
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: o.id));
                showToast(context, 'Order ID copied');
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.terracotta,
        onRefresh: () async => o != null ? _track() : null,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (_loading && o == null && _direct)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_direct || (_error != null && o == null)) _searchForm(),
            if (o != null) ..._details(o),
          ],
        ),
      ),
    );
  }

  Widget _searchForm() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.sand,
                child: Icon(Icons.local_shipping_outlined, color: AppColors.terracotta, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Where’s my order?', style: AppText.sans(size: 17, weight: FontWeight.w800)),
                    Text('Enter your order ID and the phone or email used at checkout.', style: AppText.muted(size: 12.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SectionCard(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _orderId,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Order ID', hintText: 'e.g. CD104520', prefixIcon: Icon(Icons.tag_rounded)),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Enter your order ID' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contact,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Phone or email', prefixIcon: Icon(Icons.alternate_email_rounded)),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Enter phone or email' : null,
                  onFieldSubmitted: (_) => _track(),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _loading ? null : _track,
                  child: BusyLabel(busy: _loading, label: 'TRACK ORDER'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  _Notice(
                    color: const Color(0xFFFEF2F2),
                    border: const Color(0xFFFECACA),
                    icon: Icons.error_outline_rounded,
                    iconColor: AppColors.danger,
                    title: _error!,
                    body: 'Check the order ID from your confirmation and use the same phone or email you checked out with.',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _details(Order o) {
    final current = o.stageIndex;
    final color = statusColor(o.status);
    return [
      // Status header
      Container(
        color: Colors.white,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(statusIcon(o.status), color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.status,
                    style: AppText.sans(size: 17, weight: FontWeight.w800, color: color),
                  ),
                  Text(
                    'Placed on ${formatDate(o.date)}${o.courier != null ? ' · ${o.courier}' : ''}${o.awb != null ? ' · AWB ${o.awb}' : ''}',
                    style: AppText.muted(size: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (o.isPaymentPending)
        const _Notice(
          color: Color(0xFFEFF6FF),
          border: Color(0xFFBFDBFE),
          icon: Icons.info_outline_rounded,
          iconColor: Color(0xFF2563EB),
          title: 'Waiting for payment',
          body: 'This order is confirmed as soon as the online payment goes through. If money was debited, it will update shortly. You can pay from My orders.',
          margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
        )
      else if (o.isCancelled)
        const _Notice(
          color: Color(0xFFFFFBEB),
          border: Color(0xFFFDE68A),
          icon: Icons.warning_amber_rounded,
          iconColor: Color(0xFFD97706),
          title: 'This order was cancelled',
          body: 'If you didn’t request this, please contact us — we’re happy to help.',
          margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
        )
      else
        SectionCard(
          title: 'Tracking',
          child: Column(
            children: [
              for (var i = 0; i < Order.stages.length; i++)
                _StageRow(
                  icon: _stageIcons[i],
                  title: _stageTitles[i],
                  date: i <= current ? shortDate(o.reachedAt(Order.stages[i])) : '',
                  done: i <= current,
                  isLast: i == Order.stages.length - 1,
                  lineDone: i < current,
                ),
            ],
          ),
        ),
      SectionCard(
        title: 'Items (${o.itemCount})',
        child: Column(
          children: [
            for (final it in o.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    AppImage(it.image, width: 56, height: 56, radius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.name, style: AppText.sans(size: 13.5, weight: FontWeight.w600)),
                          Text(['Qty ${it.quantity}', ?it.pack, ?it.color, ?it.fragrance].join(' · '), style: AppText.muted(size: 12)),
                        ],
                      ),
                    ),
                    Text(formatPrice(it.price * it.quantity), style: AppText.sans(weight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
      ),
      SectionCard(
        title: 'Payment summary',
        child: Column(
          children: [
            SummaryRow('Subtotal', formatPrice(o.subtotal)),
            if (o.discount > 0) SummaryRow('Discount${o.couponCode == null ? '' : ' (${o.couponCode})'}', '− ${formatPrice(o.discount)}', accent: true),
            SummaryRow('Shipping', o.shipping == 0 ? 'FREE' : formatPrice(o.shipping)),
            const Divider(height: 18),
            SummaryRow('Total', formatPrice(o.total), bold: true),
            SummaryRow('Payment', '${o.paymentMethod.toUpperCase()} · ${o.paymentStatus}'),
          ],
        ),
      ),
      SectionCard(
        title: 'Delivery address',
        child: Text('${o.customerName}\n${o.address}', style: AppText.sans(size: 13.5, height: 1.5)),
      ),
      if (o.giftNote?.isNotEmpty ?? false)
        SectionCard(
          title: 'Gift note',
          child: Text(o.giftNote!, style: AppText.sans(size: 13.5)),
        ),
      SectionCard(
        title: 'Need help with this order?',
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Launcher.whatsapp('Hi Jyotessa! I need help with order #${o.id}.'),
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: const Text('WhatsApp'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(onPressed: Launcher.call, icon: const Icon(Icons.call_outlined, size: 18), label: const Text('Call')),
            ),
          ],
        ),
      ),
      if (o.status == 'Delivered')
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ElevatedButton.icon(onPressed: Launcher.review, icon: const Icon(Icons.star_rounded), label: const Text('Loved it? Rate us on Google')),
        ),
    ];
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.icon, required this.title, required this.date, required this.done, required this.isLast, required this.lineDone});
  final IconData icon;
  final String title;
  final String date;
  final bool done;
  final bool isLast;
  final bool lineDone;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF168A4C);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: done ? green : AppColors.linen,
                child: Icon(done ? Icons.check_rounded : icon, size: 16, color: done ? Colors.white : AppColors.ash),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 2), color: lineDone ? green : AppColors.linen),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: isLast ? 0 : 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppText.sans(weight: done ? FontWeight.w700 : FontWeight.w500, color: done ? AppColors.charcoal : AppColors.ash),
                    ),
                  ),
                  Text(date, style: AppText.muted(size: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.color, required this.border, required this.icon, required this.iconColor, required this.title, required this.body, this.margin});
  final Color color, border, iconColor;
  final IconData icon;
  final String title, body;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$title\n',
                  style: AppText.sans(weight: FontWeight.w700),
                ),
                TextSpan(text: body),
              ],
            ),
            style: AppText.sans(size: 13),
          ),
        ),
      ],
    ),
  );
}
