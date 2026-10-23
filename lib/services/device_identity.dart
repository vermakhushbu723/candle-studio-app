import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../core/storage/local_storage.dart';

/// Identity of this phone for one-per-device offers (Follow & Save).
/// - deviceId: random ID created once and kept in app storage
/// - fingerprint: hash of the phone's hardware details, so a reinstall on the same phone is still recognised
class DeviceIdentity {
  DeviceIdentity._();

  static String deviceId() {
    final saved = LocalStorage.read<String>(LocalStorage.deviceId);
    if (saved != null && saved.length >= 8) return saved;
    final r = Random.secure();
    final id = 'app-${List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
    LocalStorage.write(LocalStorage.deviceId, id);
    return id;
  }

  static Future<String?> fingerprint() async {
    try {
      final info = DeviceInfoPlugin();
      String traits;
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        traits = [a.brand, a.manufacturer, a.model, a.device, a.hardware, a.board, a.fingerprint, a.version.sdkInt].join('|');
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        traits = [i.model, i.utsname.machine, i.identifierForVendor, i.systemVersion].join('|');
      } else {
        return null;
      }
      return sha256.convert(utf8.encode(traits)).toString().substring(0, 40);
    } catch (_) {
      return null;
    }
  }
}
