import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../state/repositories.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';
import 'user_avatar.dart';

/// Edit name, email and mobile (PUT /auth/me).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final _user = ref.read(sessionProvider);
  late final _name = TextEditingController(text: _user?.name);
  late final _email = TextEditingController(text: _user?.email);
  late final _phone = TextEditingController(text: _user?.phone);
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _user == null) return;
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(authRepositoryProvider)
          .updateMe(_user.token, name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim());
      ref.read(sessionProvider.notifier).signIn(updated);
      if (!mounted) return;
      showToast(context, 'Profile updated');
      context.pop();
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.lock_outline_rounded, title: 'Please log in', actionLabel: 'Log in', onAction: () => context.pushReplacement('/login')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: UserAvatar(user: _user, size: 84)),
            const SizedBox(height: 8),
            if (_user.loginMethod == 'google') Center(child: Text('Photo from your Google account', style: AppText.muted(size: 12))),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded)),
              validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty || RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) ? null : 'Please enter a valid email',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'Mobile', prefixText: '+91 ', prefixIcon: Icon(Icons.phone_outlined), counterText: ''),
              validator: (v) => (v == null || v.trim().isEmpty || RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) ? null : '10-digit mobile number',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
