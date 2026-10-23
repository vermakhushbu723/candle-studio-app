import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/offer_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/support_repository.dart';

final catalogRepositoryProvider = Provider((_) => CatalogRepository());
final authRepositoryProvider = Provider((_) => AuthRepository());
final orderRepositoryProvider = Provider((_) => OrderRepository());
final supportRepositoryProvider = Provider((_) => SupportRepository());
final offerRepositoryProvider = Provider((_) => OfferRepository());
