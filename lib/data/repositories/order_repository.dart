import '../../core/network/api_client.dart';
import '../models/order.dart';

/// Checkout details collected on the Shipping step.
class CheckoutDetails {
  const CheckoutDetails({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.line1,
    required this.city,
    required this.state,
    required this.pincode,
    this.giftNote,
  });
  final String fullName, phone, email, line1, city, state, pincode;
  final String? giftNote;
}

/// Coupon returned by POST /coupons/validate.
class Coupon {
  const Coupon({required this.code, required this.type, required this.value, this.minOrder = 0, this.maxDiscount});
  final String code;
  final String type; // percent | flat
  final int value;
  final int minOrder;
  final int? maxDiscount;

  /// Same maths as the API (coupon.controller.ts).
  int discountFor(int subtotal) {
    if (subtotal < minOrder) return 0;
    var d = type == 'percent' ? (subtotal * value / 100).round() : value;
    if (maxDiscount != null && maxDiscount! > 0) d = d < maxDiscount! ? d : maxDiscount!;
    return d < subtotal ? d : subtotal;
  }

  factory Coupon.fromJson(Map<String, dynamic> j) => Coupon(
    code: '${j['code']}',
    type: '${j['type'] ?? 'percent'}',
    value: (j['value'] as num?)?.toInt() ?? 0,
    minOrder: (j['minOrder'] as num?)?.toInt() ?? 0,
    maxDiscount: (j['maxDiscount'] as num?)?.toInt(),
  );
}

class OrderRepository {
  PlacedOrder _placed(Map<String, dynamic> r) => PlacedOrder(
    Order.fromJson(r['order'] as Map<String, dynamic>),
    r['razorpay'] is Map ? RazorpayCheckout.fromJson(r['razorpay'] as Map<String, dynamic>) : null,
  );

  /// POST /coupons/validate
  Future<({Coupon coupon, String message})> validateCoupon(String code, int subtotal) async {
    final r = await api.post('/coupons/validate', {'code': code, 'subtotal': subtotal});
    return (coupon: Coupon.fromJson(r['coupon'] as Map<String, dynamic>), message: '${r['message'] ?? '$code applied'}');
  }

  /// POST /orders (login required). Online payments come back with Razorpay options.
  Future<PlacedOrder> create({
    required CheckoutDetails details,
    required String payment, // upi | card | cod
    required List<Map<String, dynamic>> items,
    String? couponCode,
  }) async {
    final r = await api.post('/orders', {
      'fullName': details.fullName,
      'phone': details.phone,
      'email': details.email,
      'line1': details.line1,
      'city': details.city,
      'state': details.state,
      'pincode': details.pincode,
      if (details.giftNote != null && details.giftNote!.isNotEmpty) 'giftNote': details.giftNote,
      'payment': payment,
      'couponCode': couponCode,
      'items': items,
    });
    return _placed(r);
  }

  /// POST /orders/:id/verify-payment — the API checks Razorpay's signature.
  Future<Order> verifyPayment(String orderId, {required String razorpayOrderId, required String paymentId, required String signature}) async {
    final r = await api.post('/orders/$orderId/verify-payment', {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature,
    });
    return Order.fromJson(r['order'] as Map<String, dynamic>);
  }

  /// POST /orders/:id/retry-payment — new Razorpay options for an unpaid order.
  Future<PlacedOrder> retryPayment(String orderId) async => _placed(await api.post('/orders/$orderId/retry-payment'));

  /// GET /orders/mine
  Future<List<Order>> myOrders() async {
    final r = await api.get('/orders/mine');
    return (r['orders'] as List? ?? []).map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /orders/track/:id?contact= — works without login.
  Future<Order> track(String orderId, String contact) async {
    final r = await api.get('/orders/track/${Uri.encodeComponent(orderId.trim().toUpperCase())}', query: {'contact': contact.trim()});
    return Order.fromJson(r['order'] as Map<String, dynamic>);
  }
}
