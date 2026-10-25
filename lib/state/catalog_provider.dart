import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/content/catalog_content.dart';
import '../data/models/category.dart';
import '../data/models/product.dart';
import '../data/models/shipping_settings.dart';
import 'repositories.dart';

/// Live catalogue: products + admin collections + shipping settings.
class Catalog {
  Catalog({required this.products, required this.collections, required this.shipping}) : _byId = {for (final p in products) p.id: p};

  final List<Product> products;
  final List<Category> collections;
  final ShippingSettings shipping;
  final Map<String, Product> _byId;

  Product? product(String id) => _byId[id];

  /// Product categories + collections (same list the website shows in Shop filters).
  List<Category> get categories => [...productCategories, ...collections];

  Category? category(String? id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Badge-marked bestsellers, or the single pieces when nothing is marked (same as the website).
  List<Product> get bestsellers {
    final marked = products.where((p) => bestsellerBadges.contains(p.badge)).toList();
    return marked.isNotEmpty ? marked : products.where((p) => p.isSingle).toList();
  }

  /// True when a product belongs to a category, directly or through a collection.
  bool inCategory(Product p, String id) => p.category == id || p.collections.contains(id);

  int countIn(String id) => products.where((p) => inCategory(p, id)).length;
}

class CatalogNotifier extends AsyncNotifier<Catalog> {
  @override
  Future<Catalog> build() => _load();

  Future<Catalog> _load() async {
    final repo = ref.read(catalogRepositoryProvider);
    final results = await Future.wait([repo.products(), repo.collections()]);
    // Shipping falls back to the defaults if the settings call fails
    final shipping = await repo.shipping().catchError((_) => ShippingSettings.defaults);
    return Catalog(products: results[0] as List<Product>, collections: results[1] as List<Category>, shipping: shipping);
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    if (previous == null) state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
    if (state.hasError && previous != null) state = AsyncData(previous); // keep showing the old catalogue
  }
}

final catalogProvider = AsyncNotifierProvider<CatalogNotifier, Catalog>(CatalogNotifier.new);

/// Shipping settings, with defaults while the catalogue loads.
final shippingProvider = Provider<ShippingSettings>((ref) => ref.watch(catalogProvider).valueOrNull?.shipping ?? ShippingSettings.defaults);
