import '../../core/utils/format.dart';

enum ShippingMode { free, threshold, flat }

/// Admin → Settings → Shipping charges (GET /settings). Same rules as the API (models/Setting.ts).
class ShippingSettings {
  const ShippingSettings({required this.shippingFee, required this.freeShippingEnabled, required this.freeShippingAbove});

  /// Used until the API answers (and if it is unreachable).
  static const defaults = ShippingSettings(shippingFee: 79, freeShippingEnabled: true, freeShippingAbove: 899);

  final int shippingFee;
  final bool freeShippingEnabled;
  final int freeShippingAbove;

  factory ShippingSettings.fromJson(Map<String, dynamic> j) => ShippingSettings(
    shippingFee: (j['shippingFee'] as num?)?.toInt() ?? defaults.shippingFee,
    freeShippingEnabled: j['freeShippingEnabled'] as bool? ?? defaults.freeShippingEnabled,
    freeShippingAbove: (j['freeShippingAbove'] as num?)?.toInt() ?? defaults.freeShippingAbove,
  );

  ShippingMode get mode => shippingFee == 0
      ? ShippingMode.free
      : freeShippingEnabled
      ? ShippingMode.threshold
      : ShippingMode.flat;

  /// Shipping charge for an amount after discount.
  int chargeFor(int amountAfterDiscount) {
    if (amountAfterDiscount == 0 || mode == ShippingMode.free) return 0;
    if (mode == ShippingMode.threshold && amountAfterDiscount >= freeShippingAbove) return 0;
    return shippingFee;
  }

  /// How much more to add for free shipping (null when there is no threshold).
  int? remainingForFree(int amountAfterDiscount) => mode == ShippingMode.threshold ? (freeShippingAbove - amountAfterDiscount).clamp(0, 1 << 31) : null;

  /// "Free shipping above ₹899"
  String get short => switch (mode) {
    ShippingMode.free => 'Free shipping on every order',
    ShippingMode.threshold => 'Free shipping above ${formatPrice(freeShippingAbove)}',
    ShippingMode.flat => 'Flat ${formatPrice(shippingFee)} shipping',
  };

  /// One full sentence for FAQs, policies and the chatbot.
  String get sentence => switch (mode) {
    ShippingMode.free => 'Shipping is free on every order.',
    ShippingMode.threshold => 'Shipping is free on orders above ${formatPrice(freeShippingAbove)}; a flat ${formatPrice(shippingFee)} applies below that.',
    ShippingMode.flat => 'A flat ${formatPrice(shippingFee)} shipping charge applies to every order.',
  };

  ({String title, String text}) get perk => switch (mode) {
    ShippingMode.free => (title: 'Free shipping', text: 'On every order'),
    ShippingMode.threshold => (title: 'Free shipping', text: 'On orders above ${formatPrice(freeShippingAbove)}'),
    ShippingMode.flat => (title: 'Flat ${formatPrice(shippingFee)} shipping', text: 'Pan-India delivery'),
  };

  /// Replaces {shipping} / {shippingShort} placeholders in copy.
  String fill(String text) => text.replaceAll('{shipping}', sentence).replaceAll('{shippingShort}', short);
}
