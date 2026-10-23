import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../data/models/user.dart';
import 'repositories.dart';

/// The logged-in customer (null when logged out). Persisted so the app stays signed in.
class SessionNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    final saved = LocalStorage.read<Map<String, dynamic>>(LocalStorage.session);
    final user = saved == null ? null : AppUser.fromStorage(saved);
    final valid = user != null && user.token.isNotEmpty ? user : null;
    api.tokenReader = () => state?.token;
    return valid;
  }

  void signIn(AppUser user) {
    state = user;
    LocalStorage.write(LocalStorage.session, user.toJson());
  }

  void signOut() {
    state = null;
    LocalStorage.write(LocalStorage.session, null);
  }

  /// GET /auth/me — refreshes name/photo and drops an expired or blocked session.
  Future<void> refresh() async {
    final current = state;
    if (current == null) return;
    try {
      signIn(await ref.read(authRepositoryProvider).me(current.token));
    } on ApiException catch (e) {
      if (e.isUnauthorized) signOut();
    }
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, AppUser?>(SessionNotifier.new);
