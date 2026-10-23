import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/models/user.dart';
import '../../services/push_service.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';
import 'widgets/phone_otp_login.dart';

/// Log in / sign up — opened from Account, Checkout (?next=/checkout), Follow & Save…
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key, this.next});
  final String? next;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void signedIn(AppUser user) {
      ref.read(sessionProvider.notifier).signIn(user);
      PushService.instance.linkDevice(); // link this phone's notifications to the account
      showToast(context, 'Welcome to Jyotessa, ${firstName(user.name)}!');
      if (next != null) {
        context.pushReplacement(next!);
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go('/account');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [TextButton(onPressed: () => context.canPop() ? context.pop() : context.go('/'), child: const Text('SKIP'))],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Center(
              child: Container(
                width: 92,
                height: 92,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.caramel.withValues(alpha: 0.5)),
                ),
                child: Image.asset('assets/images/logo_mark.png'),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Log in or sign up',
              textAlign: TextAlign.center,
              style: AppText.sans(size: 24, weight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Use your mobile number — no password needed.\nNew here? We’ll create your account.',
              textAlign: TextAlign.center,
              style: AppText.muted(size: 14),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (icon, text) in [
                  (Icons.local_shipping_outlined, 'Track orders'),
                  (Icons.favorite_border_rounded, 'Wishlist'),
                  (Icons.bolt_rounded, 'Fast checkout'),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Icon(icon, size: 20, color: AppColors.terracotta),
                        const SizedBox(height: 4),
                        Text(
                          text,
                          style: AppText.sans(size: 11, weight: FontWeight.w600, color: AppColors.ash),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            PhoneOtpLogin(onSignedIn: signedIn),
            const SizedBox(height: 18),
            Center(
              child: TextButton.icon(
                onPressed: () => context.push('/track-order'),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: const Text('Track an order without logging in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
