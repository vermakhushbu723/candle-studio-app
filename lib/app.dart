import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/push_service.dart';
import 'state/catalog_provider.dart';
import 'state/session_provider.dart';

class JyotessaApp extends ConsumerStatefulWidget {
  const JyotessaApp({super.key});

  @override
  ConsumerState<JyotessaApp> createState() => _JyotessaAppState();
}

class _JyotessaAppState extends ConsumerState<JyotessaApp> {
  @override
  void initState() {
    super.initState();
    // Start loading the catalogue during the splash, refresh the profile and re-link this device for push
    ref.read(catalogProvider);
    Future.microtask(() async {
      await ref.read(sessionProvider.notifier).refresh();
      if (ref.read(sessionProvider) != null) PushService.instance.linkDevice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jyotessa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      // Keep content above the phone's gesture/navigation bar on every screen (Android 15 draws edge-to-edge)
      builder: (context, child) => ColoredBox(
        color: Colors.white,
        child: SafeArea(top: false, left: false, right: false, child: child ?? const SizedBox()),
      ),
    );
  }
}
