import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/local_storage.dart';
import '../data/models/product.dart';
import '../data/repositories/order_repository.dart';
import 'catalog_provider.dart';

/// One cart row. The same product with two fragrances is two rows.
class CartItem {
  const CartItem({required this.productId, this.fragrance, required this.quantity});
  final String productId;
  final String? fragrance;
  final int quantity;

  String get key => '${productId}__${fragrance ?? 'default'}';

  CartItem copyWith({int? quantity}) => CartItem(productId: productId, fragrance: fragrance, quantity: quantity ?? this.quantity);

  Map<String, dynamic> toJson() => {'productId': productId, 'fragrance': fragrance, 'quantity': quantity};
  factory CartItem.fromJson(Map<String, dynamic> j) =>
      CartItem(productId: '${j['productId']}', fragrance: j['fragrance'] as String?, quantity: (j['quantity'] as num?)?.toInt() ?? 1);
}

class CartState {
  const CartState({this.items = const [], this.coupon});
  final List<CartItem> items;
  final Coupon? coupon;
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    final saved = LocalStorage.read<List<dynamic>>(LocalStorage.cart) ?? [];
    return CartState(items: saved.map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map))).toList());
  }

  void _set(List<CartItem> items, {Coupon? coupon, bool clearCoupon = false}) {
    state = CartState(items: items, coupon: clearCoupon ? null : (coupon ?? state.coupon));
    LocalStorage.write(LocalStorage.cart, items.map((i) => i.toJson()).toList());
  }

  void add(String productId, {int quantity = 1, String? fragrance}) {
    final item = CartItem(productId: productId, fragrance: fragrance, quantity: quantity);
    final existing = state.items.indexWhere((i) => i.key == item.key);
    final items = [...state.items];
    if (existing >= 0) {
      items[existing] = items[existing].copyWith(quantity: (items[existing].quantity + quantity).clamp(1, 20));
    } else {
      items.add(item);
    }
    _set(items);
  }

  void setQuantity(String key, int quantity) {
    if (quantity <= 0) return remove(key);
    _set([for (final i in state.items) i.key == key ? i.copyWith(quantity: quantity.clamp(1, 20)) : i]);
  }

  void remove(String key) => _set(state.items.where((i) => i.key != key).toList());

  void clear() => _set([], clearCoupon: true);

  void applyCoupon(Coupon coupon) => _set(state.items, coupon: coupon);
  void removeCoupon() => _set(state.items, clearCoupon: true);
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

/// A cart row joined with its product.
class CartLine {
  const CartLine(this.item, this.product);
  final CartItem item;
  final Product product;
  int get lineTotal => product.price * item.quantity;
}

/// Totals — same maths as the API so the summary matches the final order.
class CartTotals {
  const CartTotals({
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.count,
    this.coupon,
    this.remainingForFree,
  });
  final List<CartLine> lines;
  final int subtotal;
  final int discount;
  final int shipping;
  final int count;
  final Coupon? coupon; // only while the cart still meets its minimum order
  final int? remainingForFree;
  int get total => subtotal - discount + shipping;
  bool get isEmpty => lines.isEmpty;
}

final cartTotalsProvider = Provider<CartTotals>((ref) {
  final cart = ref.watch(cartProvider);
  final catalog = ref.watch(catalogProvider).valueOrNull;
  final shipping = ref.watch(shippingProvider);
  final lines = [
    for (final i in cart.items)
      if (catalog?.product(i.productId) case final p?) CartLine(i, p),
  ];
  final subtotal = lines.fold(0, (s, l) => s + l.lineTotal);
  final discount = cart.coupon?.discountFor(subtotal) ?? 0;
  final afterDiscount = subtotal - discount;
  return CartTotals(
    lines: lines,
    subtotal: subtotal,
    discount: discount,
    shipping: shipping.chargeFor(afterDiscount),
    count: lines.fold(0, (s, l) => s + l.item.quantity),
    coupon: discount > 0 ? cart.coupon : null,
    remainingForFree: shipping.remainingForFree(afterDiscount),
  );
});
