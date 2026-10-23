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

const productLines = {
  'pearled': ProductLine(
    id: 'pearled',
    title: 'Pearled Candles',
    kicker: 'Pour · Wick · Glow · Repeat',
    description: 'Loose soy wax pearls you pour into any vessel. Spill-proof, auto-extinguishing and endlessly reusable.',
    perks: ['Spill-proof', 'Reusable', 'Any vessel'],
    productId: 'endless-refill',
  ),
  'handcrafted': ProductLine(
    id: 'handcrafted',
    title: 'Handcrafted Candles',
    kicker: 'Built from India, poured by hand',
    description: 'Sculpted, food-inspired and floral soy candles that smell like chai breaks, monsoon evenings and Diwali nights.',
    perks: ['Hand-poured', 'Indian scents', 'Gift-ready'],
    productId: 'heart-bowl-candle',
  ),
};

/// Product categories. Collections (Diwali, Valentine…) come from the admin via GET /collections.
const productCategories = [
  Category(id: 'pearl-kits', line: 'pearled', label: 'Pearl Decor Kits', tone: '#EADBC8', image: '/images/products/kit-ocean.webp'),
  Category(id: 'refills', line: 'pearled', label: 'Refills & Scent Bar', tone: '#E8D5C4', image: '/images/products/kit-refill.webp'),
  Category(id: 'food-inspired', line: 'handcrafted', label: 'Food Inspired', tone: '#F3D9BF', image: '/images/products/chai-parle-g-candle-1.jpg'),
  Category(id: 'love-in-the-air', line: 'handcrafted', label: 'Love in the Air', tone: '#F7E4D8', image: '/images/products/heart-bowl-candle-1.jpg'),
  Category(id: 'floral', line: 'handcrafted', label: 'Floral', tone: '#F6E1EA', image: '/images/products/bouquet-candle-1.jpg'),
  Category(id: 'luxury', line: 'handcrafted', label: 'Luxury & Festive', tone: '#F5E6C4', image: '/images/products/kamal-jyoti-urli-1.webp'),
  Category(id: 'wax-fresheners', line: 'handcrafted', label: 'Wax Fresheners', tone: '#E6EDE2', image: '/images/products/wardrobe-wax-sachets-1.jpg'),
];

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
