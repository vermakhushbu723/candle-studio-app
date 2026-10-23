import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Intro after the native splash: the logo glows in, the tagline writes in, then Home opens
/// (same idea as the website's IntroLoader).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    final text = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.45, 1, curve: Curves.easeOut),
    );
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: glow,
              builder: (_, child) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.caramel.withValues(alpha: 0.35 * glow.value), blurRadius: 90, spreadRadius: 10)],
                ),
                child: Opacity(
                  opacity: glow.value,
                  child: Transform.scale(scale: 0.85 + 0.15 * glow.value, child: child),
                ),
              ),
              child: Image.asset('assets/images/logo_light.png', width: 220),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: text,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(text),
                child: Text(
                  'Light up every moment',
                  style: AppText.serif(size: 18, color: AppColors.caramel, style: FontStyle.italic),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
