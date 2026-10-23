import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../core/config/app_config.dart';
import '../data/content/site_content.dart';
import '../data/models/order.dart';

/// What Razorpay hands back after a successful payment (verified by the API).
class RazorpayResult {
  const RazorpayResult({required this.orderId, required this.paymentId, required this.signature});
  final String orderId;
  final String paymentId;
  final String signature;
}

class PaymentCancelled implements Exception {
  @override
  String toString() => 'Payment was not completed.';
}

/// Opens Razorpay Checkout with the options the API returned for an order.
class RazorpayService {
  Future<RazorpayResult> pay(RazorpayCheckout opts) {
    final razorpay = Razorpay();
    final done = Completer<RazorpayResult>();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      if (!done.isCompleted) done.complete(RazorpayResult(orderId: r.orderId ?? opts.orderId, paymentId: r.paymentId ?? '', signature: r.signature ?? ''));
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      if (done.isCompleted) return;
      // Code 2 = the customer closed the payment sheet
      if (r.code == Razorpay.PAYMENT_CANCELLED) {
        done.completeError(PaymentCancelled());
      } else {
        done.completeError(Exception(r.message?.isNotEmpty ?? false ? r.message : 'Payment failed. Please try again.'));
      }
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});

    razorpay.open({
      'key': opts.key,
      'order_id': opts.orderId,
      'amount': opts.amount,
      'currency': opts.currency,
      'name': Site.name,
      'description': 'Candle order',
      'prefill': {...opts.prefill, if (opts.method != null) 'method': opts.method},
      'theme': {'color': AppConfig.brandColorHex},
    });

    return done.future.whenComplete(razorpay.clear);
  }
}
