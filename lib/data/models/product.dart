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
    this.cover,
    this.tone,
    this.stock,
  });

  final String id; // slug
  final String name;
  final String subtitle;
  final String line; // pearled | handcrafted
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
  final String? cover; // visual.image
  final String? tone; // visual.bg
  final int? stock;

  bool get isPearled => line == 'pearled';
  String get lineLabel => isPearled ? 'Pearled' : 'Handcrafted';
  String? get image => cover ?? (images.isNotEmpty ? images.first : null);
  bool get outOfStock => stock != null && stock! <= 0;

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
      cover: visual['image'] as String?,
      tone: visual['bg'] as String?,
      stock: (j['stock'] as num?)?.toInt(),
    );
  }
}
