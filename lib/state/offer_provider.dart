import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/offer_repository.dart';
import 'repositories.dart';
import 'session_provider.dart';

/// Follow & Save offer + this account's coupon (reloads on login/logout).
final followOfferProvider = FutureProvider.autoDispose<FollowOffer>((ref) {
  ref.watch(sessionProvider.select((u) => u?.token));
  return ref.read(offerRepositoryProvider).followOffer();
});
