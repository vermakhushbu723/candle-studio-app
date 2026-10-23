import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/local_storage.dart';

/// Saved product IDs (kept on the device, like the website).
class WishlistNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => (LocalStorage.read<List<dynamic>>(LocalStorage.wishlist) ?? []).map((e) => '$e').toList();

  /// Returns true when the product is now saved.
  bool toggle(String id) {
    final saved = !state.contains(id);
    state = saved ? [...state, id] : state.where((x) => x != id).toList();
    LocalStorage.write(LocalStorage.wishlist, state);
    return saved;
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<String>>(WishlistNotifier.new);
