import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

/// "This page blew out" — unknown links (e.g. from a notification).
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo_mark.png', width: 120),
              const SizedBox(height: 20),
              Text('404', style: AppText.eyebrow()),
              const SizedBox(height: 8),
              Text('This page blew out', style: AppText.serif(size: 30)),
              const SizedBox(height: 8),
              Text('The page you’re looking for doesn’t exist or has moved.', textAlign: TextAlign.center, style: AppText.muted(size: 14)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => context.go('/'), child: const Text('Relight the homepage')),
            ],
          ),
        ),
      ),
    );
  }
}
