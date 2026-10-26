import '../content/catalog_content.dart';

/// A colour the customer can pick; its photos replace the gallery when chosen.
class ProductColor {
  const ProductColor({required this.name, this.hex = '', this.images = const []});
  final String name;
  final String hex;
  final List<String> images;

  factory ProductColor.fromJson(Map<String, dynamic> j) => ProductColor(
    name: '${j['name'] ?? ''}',
    hex: '${j['hex'] ?? ''}',
    images: j['images'] is List ? (j['images'] as List).map((e) => '$e').toList() : const [],
  );
}

/// A candle from GET /products (same shape as the website's catalogue).
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.line,
    required this.category,
    required this.collections,
    required this.price,
    this.compareAt,
    required this.rating,
    required this.reviews,
    this.badge,
    required this.moods,
    required this.tagline,
    required this.description,
    required this.includes,
    required this.bestFor,
    required this.howToUse,
    required this.hasFragrances,
    required this.images,
    this.colors = const [],
    this.variantGroup = '',
    this.variantLabel = '',
    this.cover,
    this.tone,
    this.stock,
  });

  final String id; // slug
  final String name;
  final String subtitle;
  final String line; // handcrafted
  final String category;
  final List<String> collections;
  final int price;
  final int? compareAt;
  final double rating;
  final int reviews;
  final String? badge;
  final List<String> moods;
  final String tagline;
  final String description;
  final List<String> includes;
  final String bestFor;
  final List<String> howToUse;
  final bool hasFragrances;
  final List<String> images;
  final List<ProductColor> colors;
  final String variantGroup; // pack sizes of one design share a group
  final String variantLabel; // e.g. "Pack of 2"
  final String? cover; // visual.image
  final String? tone; // visual.bg
  final int? stock;

  String get categoryLabel => categoryLabelOf(category) ?? 'Handcrafted';
  bool get isSingle => isSinglePiece(name, subtitle);
  bool get hasReviews => reviews > 0;
  String? get image => cover ?? (images.isNotEmpty ? images.first : null);
  bool get outOfStock => stock != null && stock! <= 0;

  /// Photos for a colour, falling back to the product photos.
  List<String> imagesFor(String? color) {
    for (final c in colors) {
      if (c.name == color && c.images.isNotEmpty) return c.images;
    }
    return images.isEmpty ? [?image] : images;
  }

  static List<String> _strings(Object? v) => v is List ? v.map((e) => '$e').toList() : const [];

  factory Product.fromJson(Map<String, dynamic> j) {
    final visual = j['visual'] is Map ? j['visual'] as Map : const {};
    return Product(
      id: (j['id'] ?? j['slug'] ?? '') as String,
      name: j['name'] as String? ?? '',
      subtitle: j['subtitle'] as String? ?? '',
      line: j['line'] as String? ?? 'handcrafted',
      category: j['category'] as String? ?? '',
      collections: _strings(j['collections']),
      price: (j['price'] as num?)?.toInt() ?? 0,
      compareAt: (j['compareAt'] as num?)?.toInt(),
      rating: (j['rating'] as num?)?.toDouble() ?? 5,
      reviews: (j['reviews'] as num?)?.toInt() ?? 0,
      badge: (j['badge'] as String?)?.trim().isEmpty ?? true ? null : j['badge'] as String,
      moods: _strings(j['moods']),
      tagline: j['tagline'] as String? ?? '',
      description: j['description'] as String? ?? '',
      includes: _strings(j['includes']),
      bestFor: j['bestFor'] as String? ?? '',
      howToUse: _strings(j['howToUse']),
      hasFragrances: j['fragrances'] == true,
      images: _strings(j['images']),
      colors: j['colors'] is List
          ? [for (final c in j['colors'] as List) if (c is Map) ProductColor.fromJson(Map<String, dynamic>.from(c))]
          : const [],
      variantGroup: j['variantGroup'] as String? ?? '',
      variantLabel: j['variantLabel'] as String? ?? '',
      cover: visual['image'] as String?,
      tone: visual['bg'] as String?,
      stock: (j['stock'] as num?)?.toInt(),
    );
  }
}
