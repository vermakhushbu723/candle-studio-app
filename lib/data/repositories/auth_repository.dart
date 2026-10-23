import '../../core/network/api_client.dart';
import '../models/user.dart';

/// Result of POST /auth/otp/send.
class OtpSent {
  const OtpSent({required this.isNewUser, required this.message, this.devOtp});
  final bool isNewUser;
  final String message;
  final String? devOtp; // shown on screen while the server runs in OTP test mode
}

/// Passwordless customer login: mobile + OTP, or Google.
class AuthRepository {
  AppUser _session(Map<String, dynamic> r) => AppUser.fromJson(r['user'] as Map<String, dynamic>, r['token'] as String);

  /// POST /auth/otp/send
  Future<OtpSent> sendOtp(String phone) async {
    final r = await api.post('/auth/otp/send', {'phone': phone});
    return OtpSent(isNewUser: r['isNewUser'] == true, message: '${r['message'] ?? 'OTP sent'}', devOtp: r['devOtp'] as String?);
  }

  /// POST /auth/otp/verify — name (and optional email) are needed only for a new account.
  Future<AppUser> verifyOtp({required String phone, required String otp, String? name, String? email}) async {
    final r = await api.post('/auth/otp/verify', {
      'phone': phone,
      'otp': otp,
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
    });
    return _session(r);
  }

  /// POST /auth/phone/status — is this number new? (used before a Firebase SMS)
  Future<bool> isNewPhone(String phone) async => (await api.post('/auth/phone/status', {'phone': phone}))['isNewUser'] == true;

  /// POST /auth/google — Google ID token (audience = the web client ID).
  Future<AppUser> google(String idToken) async => _session(await api.post('/auth/google', {'credential': idToken}));

  /// GET /auth/me — refreshes the profile (and tells us if the session expired).
  Future<AppUser> me(String token) async {
    final r = await api.get('/auth/me');
    return AppUser.fromJson(r['user'] as Map<String, dynamic>, token);
  }

  /// PUT /auth/me — update name, email or phone.
  Future<AppUser> updateMe(String token, {String? name, String? email, String? phone}) async {
    final r = await api.put('/auth/me', {'name': ?name, if (email != null && email.isNotEmpty) 'email': email, 'phone': ?phone});
    return AppUser.fromJson(r['user'] as Map<String, dynamic>, token);
  }
}
