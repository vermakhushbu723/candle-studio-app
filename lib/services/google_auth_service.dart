import 'package:google_sign_in/google_sign_in.dart';

import '../core/config/app_config.dart';

class GoogleSignInCancelled implements Exception {}

/// "Continue with Google" → Google ID token for POST /auth/google.
///
/// Android needs an OAuth "Android" client (package com.jyotessa.jyotessa_app + the app's SHA-1)
/// in the same Google Cloud project as the web client below.
class GoogleAuthService {
  final _google = GoogleSignIn(scopes: const ['email', 'profile'], serverClientId: AppConfig.googleWebClientId);

  Future<String> idToken() async {
    await _google.signOut(); // always show the account picker
    final account = await _google.signIn();
    if (account == null) throw GoogleSignInCancelled();
    final token = (await account.authentication).idToken;
    if (token == null) throw Exception('Google did not return a sign-in token. Please try again.');
    return token;
  }

  Future<void> signOut() => _google.signOut().catchError((_) => null);
}
