/// The logged-in customer. Stored with the JWT so the app stays signed in.
class AppUser {
  const AppUser({required this.token, required this.id, required this.name, this.email, this.phone, this.avatar, this.loginMethod});

  final String token;
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? loginMethod; // phone | google

  String get contactLabel => (phone?.isNotEmpty ?? false) ? '+91 $phone' : (email ?? '');

  /// Contact used for order tracking links (email first, like the website).
  String get trackingContact => (email?.isNotEmpty ?? false) ? email! : (phone ?? '');

  factory AppUser.fromJson(Map<String, dynamic> user, String token) => AppUser(
    token: token,
    id: (user['id'] ?? user['_id'] ?? '') as String,
    name: user['name'] as String? ?? 'Friend',
    email: (user['email'] as String?)?.isEmpty ?? true ? null : user['email'] as String,
    phone: (user['phone'] as String?)?.isEmpty ?? true ? null : user['phone'] as String,
    avatar: (user['avatar'] as String?)?.isEmpty ?? true ? null : user['avatar'] as String,
    loginMethod: user['loginMethod'] as String?,
  );

  Map<String, dynamic> toJson() => {'token': token, 'id': id, 'name': name, 'email': email, 'phone': phone, 'avatar': avatar, 'loginMethod': loginMethod};

  factory AppUser.fromStorage(Map<String, dynamic> j) => AppUser.fromJson(j, j['token'] as String? ?? '');
}
