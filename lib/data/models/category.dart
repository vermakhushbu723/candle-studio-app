/// A product category (static) or an admin-managed collection (GET /collections), shown the same way.
class Category {
  const Category({
    required this.id,
    required this.label,
    required this.line, // category group (festive | home) or all (collections)
    this.image,
    this.tone,
    this.description = '',
    this.type, // festive | curated (collections only)
    this.isCollection = false,
  });

  final String id;
  final String label;
  final String line;
  final String? image;
  final String? tone;
  final String description;
  final String? type;
  final bool isCollection;

  bool get isFestive => type == 'festive';

  factory Category.fromCollectionJson(Map<String, dynamic> j) => Category(
    id: (j['id'] ?? j['slug'] ?? '') as String,
    label: j['name'] as String? ?? '',
    line: 'all',
    image: j['image'] as String?,
    tone: j['tone'] as String?,
    description: j['description'] as String? ?? '',
    type: j['type'] as String?,
    isCollection: true,
  );
}
