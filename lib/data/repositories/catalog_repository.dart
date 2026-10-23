import '../../core/network/api_client.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/shipping_settings.dart';

/// Products, collections and shop settings.
class CatalogRepository {
  /// GET /products
  Future<List<Product>> products() async {
    final r = await api.get('/products');
    return (r['products'] as List? ?? []).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /products/:slug — fresh price & stock for one product.
  Future<Product> product(String slug) async {
    final r = await api.get('/products/${Uri.encodeComponent(slug)}');
    return Product.fromJson(r['product'] as Map<String, dynamic>);
  }

  /// GET /collections — Diwali, Valentine… managed in the admin.
  Future<List<Category>> collections() async {
    final r = await api.get('/collections');
    return (r['collections'] as List? ?? []).map((e) => Category.fromCollectionJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /settings — shipping charges from Admin → Settings.
  Future<ShippingSettings> shipping() async {
    final r = await api.get('/settings');
    return r['shipping'] is Map ? ShippingSettings.fromJson(r['shipping'] as Map<String, dynamic>) : ShippingSettings.defaults;
  }
}
