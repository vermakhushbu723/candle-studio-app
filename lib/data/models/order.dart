/// An order as the API returns it (toClientOrder in order.controller.ts).
class Order {
  const Order({
    required this.id,
    this.date,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    this.couponCode,
    this.giftNote,
    required this.status,
    required this.statusHistory,
    required this.paymentMethod,
    required this.paymentStatus,
    this.courier,
    this.awb,
  });

  final String id; // e.g. CD104520
  final DateTime? date;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String address;
  final List<OrderItem> items;
  final int subtotal;
  final int discount;
  final int shipping;
  final int total;
  final String? couponCode;
  final String? giftNote;
  final String status;
  final List<StatusEntry> statusHistory;
  final String paymentMethod; // upi | card | cod
  final String paymentStatus; // Pending | Paid | Refunded | Failed
  final String? courier;
  final String? awb;

  static const stages = ['Order Placed', 'Packed', 'Shipped', 'Out for Delivery', 'Delivered'];

  bool get isPaymentPending => status == 'Payment Pending';
  bool get isCancelled => status == 'Cancelled';
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);
  int get stageIndex => stages.indexOf(status);
  String get trackingContact => customerEmail.isNotEmpty ? customerEmail : customerPhone;

  /// Last time the order reached a status (for the tracking timeline).
  DateTime? reachedAt(String s) {
    for (final h in statusHistory.reversed) {
      if (h.status == s) return h.at;
    }
    return null;
  }

  factory Order.fromJson(Map<String, dynamic> j) {
    final c = j['customer'] is Map ? j['customer'] as Map : const {};
    final a = j['address'] is Map ? j['address'] as Map : const {};
    return Order(
      id: '${j['id'] ?? ''}',
      date: DateTime.tryParse('${j['date'] ?? ''}'),
      customerName: '${c['name'] ?? ''}',
      customerEmail: '${c['email'] ?? ''}',
      customerPhone: '${c['phone'] ?? ''}',
      address: [a['line1'], a['city'], a['state'], a['pincode']].where((e) => e != null && '$e'.isNotEmpty).join(', '),
      items: (j['items'] as List? ?? []).map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
      subtotal: (j['subtotal'] as num?)?.toInt() ?? 0,
      discount: (j['discount'] as num?)?.toInt() ?? 0,
      shipping: (j['shipping'] as num?)?.toInt() ?? 0,
      total: (j['total'] as num?)?.toInt() ?? 0,
      couponCode: j['couponCode'] as String?,
      giftNote: j['giftNote'] as String?,
      status: '${j['status'] ?? ''}',
      statusHistory: (j['statusHistory'] as List? ?? []).map((e) => StatusEntry.fromJson(e as Map<String, dynamic>)).toList(),
      paymentMethod: '${j['paymentMethod'] ?? ''}',
      paymentStatus: '${j['paymentStatus'] ?? ''}',
      courier: j['courier'] as String?,
      awb: j['awb'] as String?,
    );
  }
}

class OrderItem {
  const OrderItem({required this.name, required this.quantity, required this.price, this.fragrance, this.color, this.pack, this.image});
  final String name;
  final int quantity;
  final int price;
  final String? fragrance;
  final String? color;
  final String? pack;
  final String? image;

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    name: '${j['name'] ?? ''}',
    quantity: (j['quantity'] as num?)?.toInt() ?? 1,
    price: (j['price'] as num?)?.toInt() ?? 0,
    fragrance: j['fragrance'] as String?,
    color: j['color'] as String?,
    pack: j['pack'] as String?,
    image: j['image'] as String?,
  );
}

class StatusEntry {
  const StatusEntry({required this.status, this.at});
  final String status;
  final DateTime? at;
  factory StatusEntry.fromJson(Map<String, dynamic> j) => StatusEntry(status: '${j['status'] ?? ''}', at: DateTime.tryParse('${j['at'] ?? ''}'));
}

/// Razorpay Checkout options returned with an online order (checkoutOptions in the API).
class RazorpayCheckout {
  const RazorpayCheckout({required this.key, required this.orderId, required this.amount, required this.currency, this.method, required this.prefill});
  final String key;
  final String orderId;
  final int amount; // paise
  final String currency;
  final String? method;
  final Map<String, dynamic> prefill;

  factory RazorpayCheckout.fromJson(Map<String, dynamic> j) => RazorpayCheckout(
    key: '${j['key'] ?? ''}',
    orderId: '${j['orderId'] ?? ''}',
    amount: (j['amount'] as num?)?.toInt() ?? 0,
    currency: '${j['currency'] ?? 'INR'}',
    method: j['method'] as String?,
    prefill: j['prefill'] is Map ? Map<String, dynamic>.from(j['prefill'] as Map) : {},
  );
}

/// POST /orders and /retry-payment result.
class PlacedOrder {
  const PlacedOrder(this.order, this.razorpay);
  final Order order;
  final RazorpayCheckout? razorpay;
}
