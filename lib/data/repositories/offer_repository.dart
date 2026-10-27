import '../../core/network/api_client.dart';

class FollowLink {
  const FollowLink({required this.key, required this.label, required this.url});
  final String key;
  final String label;
  final String url;
}

class PersonalCoupon {
  const PersonalCoupon({required this.code, this.expiry, required this.used, required this.percent});
  final String code;
  final DateTime? expiry;
  final bool used;
  final int percent;

  bool get expired => expiry != null && expiry!.isBefore(DateTime.now());
  bool get usable => !used && !expired;

  factory PersonalCoupon.fromJson(Map<String, dynamic> j) => PersonalCoupon(
    code: '${j['code']}',
    expiry: DateTime.tryParse('${j['expiry'] ?? ''}'),
    used: j['used'] == true,
    percent: (j['percent'] as num?)?.toInt() ?? 10,
  );
}

/// Follow & Save offer (GET /offers/follow).
class FollowOffer {
  const FollowOffer({required this.enabled, required this.percent, required this.validDays, required this.maxDiscount, required this.links, this.coupon, this.status, this.handle});
  final bool enabled;
  final int percent;
  final int validDays;
  final int maxDiscount;
  final List<FollowLink> links;
  final PersonalCoupon? coupon; // this account's coupon, once approved
  final String? status; // null (not claimed) | pending | approved
  final String? handle; // username the customer followed us from

  bool get pending => status == 'pending';

  factory FollowOffer.fromJson(Map<String, dynamic> r) {
    final o = r['offer'] as Map<String, dynamic>? ?? {};
    return FollowOffer(
      enabled: o['enabled'] != false,
      percent: (o['percent'] as num?)?.toInt() ?? 10,
      validDays: (o['validDays'] as num?)?.toInt() ?? 30,
      maxDiscount: (o['maxDiscount'] as num?)?.toInt() ?? 0,
      links: (o['links'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .map((l) => FollowLink(key: '${l['key']}', label: '${l['label']}', url: '${l['url']}'))
          .toList(),
      coupon: r['coupon'] is Map ? PersonalCoupon.fromJson(r['coupon'] as Map<String, dynamic>) : null,
      status: r['status'] as String?,
      handle: r['handle'] as String?,
    );
  }
}

class OfferRepository {
  /// GET /offers/follow — sends the token when logged in, so the account's coupon comes back too.
  Future<FollowOffer> followOffer() async => FollowOffer.fromJson(await api.get('/offers/follow'));

  /// POST /offers/follow/device — has this phone already claimed the offer?
  Future<bool> deviceUsed(String deviceId) async => (await api.post('/offers/follow/device', {'deviceId': deviceId}))['deviceUsed'] == true;

  /// POST /offers/follow/claim — one per account and per device. The coupon is switched on after the team checks the follow.
  Future<String> claim({required String deviceId, String? fingerprint, required List<String> visited, required String handle}) async {
    final r = await api.post('/offers/follow/claim', {'deviceId': deviceId, 'fingerprint': ?fingerprint, 'visited': visited, 'handle': handle});
    return '${r['message'] ?? 'Thanks! We will check and switch on your coupon soon.'}';
  }
}
