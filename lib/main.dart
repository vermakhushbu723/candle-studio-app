import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage.dart';
import 'services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));

  // Push is optional — it starts only when the Firebase app ID is configured (see AppConfig)
  PushService.instance.onOpen = openLink;
  await PushService.instance.init();

  runApp(const ProviderScope(child: JyotessaApp()));
}
