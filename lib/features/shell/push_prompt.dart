import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/push_service.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';

/// Soft "turn on notifications" prompt, as on the website: first after 15 s,
/// then every 10 minutes while notifications are off (at most 4 times a day).
class PushPrompt extends ConsumerStatefulWidget {
  const PushPrompt({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<PushPrompt> createState() => _PushPromptState();
}

class _PushPromptState extends ConsumerState<PushPrompt> {
  static const _first = Duration(seconds: 15);
  static const _every = Duration(minutes: 10);
  static const _maxPerDay = 4;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (PushService.instance.configured) _timer = Timer(_first, _maybeShow);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _maybeShow() async {
    final status = await PushService.instance.status();
    if (!mounted || status == PushStatus.granted || status == PushStatus.unsupported) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final log = LocalStorage.read<Map<String, dynamic>>(LocalStorage.pushPrompt) ?? {};
    final shown = log['day'] == today ? (log['count'] as num? ?? 0).toInt() : 0;
    // Blocked in system settings → remind once a day only
    final limit = status == PushStatus.denied ? 1 : _maxPerDay;
    if (shown >= limit) return;
    await LocalStorage.write(LocalStorage.pushPrompt, {'day': today, 'count': shown + 1});

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => _PromptSheet(denied: status == PushStatus.denied),
    );
    if (mounted && await PushService.instance.status() != PushStatus.granted) _timer = Timer(_every, _maybeShow);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _PromptSheet extends ConsumerStatefulWidget {
  const _PromptSheet({required this.denied});
  final bool denied;

  @override
  ConsumerState<_PromptSheet> createState() => _PromptSheetState();
}

class _PromptSheetState extends ConsumerState<_PromptSheet> {
  bool _busy = false;

  Future<void> _enable() async {
    setState(() => _busy = true);
    final s = await PushService.instance.enable(loggedIn: ref.read(sessionProvider) != null);
    if (!mounted) return;
    Navigator.pop(context);
    showToast(
      context,
      s == PushStatus.granted ? 'Notifications are on 🎉' : 'Notifications are blocked — allow them in your phone’s Settings → Apps → Jyotessa.',
      error: s != PushStatus.granted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.sand,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.caramel.withValues(alpha: 0.5), blurRadius: 30)],
              ),
              child: const Icon(Icons.notifications_active_rounded, size: 34, color: AppColors.terracotta),
            ),
            const SizedBox(height: 16),
            Text('Don’t miss a glow ✨', style: AppText.serif(size: 24)),
            const SizedBox(height: 8),
            Text(
              'Turn on notifications for order updates — confirmed, shipped, delivered — plus new collections and festive offers.',
              textAlign: TextAlign.center,
              style: AppText.muted(size: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _enable,
                icon: const Icon(Icons.notifications_rounded),
                label: Text(widget.denied ? 'Try again' : 'Turn on notifications'),
              ),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe later')),
          ],
        ),
      ),
    );
  }
}
