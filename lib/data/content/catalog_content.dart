import '../models/category.dart';

/// Static catalogue data shared with the website (candle-studio/src/data/products.js).

class ProductLine {
  const ProductLine({required this.id, required this.title, required this.kicker, required this.description, required this.perks, required this.productId});
  final String id;
  final String title;
  final String kicker;
  final String description;
  final List<String> perks;
  final String productId; // photo shown on the "Two ways to glow" card
}

/// Category groups (same as the website's mega menu). Category.line holds the group id.
const productLines = {
  'festive': ProductLine(
    id: 'festive',
    title: 'Festive & Gifting',
    kicker: 'Diwali · Pooja · Love',
    description: 'Terracotta diyas, lotus pooja bowls, sweet-shop candles and rose bouquets — hand-poured and gift-ready.',
    perks: ['Diyas', 'Lotus bowls', 'Rose bouquets'],
    productId: 'designer-diya',
  ),
  'home': ProductLine(
    id: 'home',
    title: 'Home & Décor',
    kicker: 'Bubbles · Glass · Tea lights',
    description: 'Bubble cubes, gel glasses, mandala tins, floating candles and tea lights for every corner of your home.',
    perks: ['Bubble cubes', 'Gel glasses', 'Tea lights'],
    productId: 'rose-bubble',
  ),
};

/// Product categories. Collections (Diwali, Valentine…) come from the admin via GET /collections.
const productCategories = [
  Category(id: 'pooja-festive', line: 'festive', label: 'Pooja & Diyas', tone: '#F5E1C0', image: '/images/products/catalog/lotus-pond.jpg', description: 'Lotus water-pond bowls and terracotta wax diyas for pooja and Diwali.'),
  Category(id: 'food-inspired', line: 'festive', label: 'Sweets & Treats', tone: '#F3D9BF', image: '/images/products/catalog/ladoo-modak.jpg', description: 'Ladoo, modak, rasgulla and dry-fruit candles that look good enough to eat.'),
  Category(id: 'floral', line: 'festive', label: 'Bouquets & Roses', tone: '#F7E4D8', image: '/images/products/catalog/yellow-rose-bouquet.jpg', description: '3D rose bouquets, blooming roses and rose gift combos.'),
  Category(id: 'cute-gifts', line: 'festive', label: 'Cute & Gifting', tone: '#FCE9D8', image: '/images/products/catalog/teddy-bear.jpg', description: 'Teddy bears and cute little candles to gift.'),
  Category(id: 'bubble-candles', line: 'home', label: 'Bubble Candles', tone: '#E6EEF5', image: '/images/products/catalog/rose-bubble.jpg', description: 'Pastel bubble cubes and rose-pattern cubes — the aesthetic favourites.'),
  Category(id: 'jars-glass', line: 'home', label: 'Jars & Glass', tone: '#EFE6DD', image: '/images/products/catalog/heart-gel-glass.jpg', description: 'Heart gel glasses and mandala tin jar candles.'),
  Category(id: 'floating-candles', line: 'home', label: 'Floating Candles', tone: '#FBE3E8', image: '/images/products/catalog/mini-rose-floating.jpg', description: 'Mini rose and daisy candles that float on water — for urlis, bowls and pools.'),
  Category(id: 'tealights', line: 'home', label: 'Tea Lights', tone: '#F6EDE4', image: '/images/products/catalog/sunflower-tealight.jpg', description: 'Floral, rainbow, scented and classic white tea lights.'),
];

String? categoryLabelOf(String? id) {
  for (final c in productCategories) {
    if (c.id == id) return c.label;
  }
  return null;
}

class Fragrance {
  const Fragrance(this.id, this.label, this.note);
  final String id;
  final String label;
  final String note;
}

const fragrances = [
  Fragrance('sandalwood', 'Mysore Sandalwood', 'Warm · Woody'),
  Fragrance('lavender', 'Lavender Vanilla', 'Calm · Soft'),
  Fragrance('jasmine', 'Night Jasmine', 'Floral · Rich'),
  Fragrance('oud', 'Amber Oud', 'Deep · Festive'),
];

String? fragranceLabel(String? id) {
  for (final f in fragrances) {
    if (f.id == id) return f.label;
  }
  return null;
}

/// Badges that make a product a "bestseller".
const bestsellerBadges = ['Most Popular', 'Bestseller', 'Hot Selling'];

final _pack = RegExp('Pack of|Gift Box|Combo', caseSensitive: false);

/// True for single pieces (not packs / combos) — the fallback bestseller list.
bool isSinglePiece(String name, String subtitle) => !_pack.hasMatch('$subtitle $name');
