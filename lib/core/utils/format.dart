import 'package:intl/intl.dart';

import '../config/app_config.dart';

final _inr = NumberFormat.decimalPattern('en_IN');

/// ₹1,099
String formatPrice(num value) => '₹${_inr.format(value)}';

/// Whole-number discount between price and the struck-through price.
int discountPercent(num price, num? compareAt) => compareAt != null && compareAt > price ? (((compareAt - price) / compareAt) * 100).round() : 0;

/// 12 Oct 2026
String formatDate(DateTime? d) => d == null ? '' : DateFormat('d MMM yyyy').format(d.toLocal());

/// 12 Oct
String shortDate(DateTime? d) => d == null ? '' : DateFormat('d MMM').format(d.toLocal());

/// Product photos are stored as site paths (`/images/products/...`) or full URLs.
String imageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return '${AppConfig.siteUrl}${path.startsWith('/') ? '' : '/'}$path';
}

/// "AB" from "Ananya Bose"
String initials(String? name) {
  final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2);
  final s = parts.map((w) => w[0].toUpperCase()).join();
  return s.isEmpty ? '?' : s;
}

String firstName(String? name) => (name ?? '').trim().split(' ').first;
