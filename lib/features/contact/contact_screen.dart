import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content/site_content.dart';
import '../../services/launcher.dart';
import '../../state/repositories.dart';
import '../../state/session_provider.dart';
import '../../widgets/common.dart';
import '../info/about_screen.dart';

/// Contact — channels, the message form (POST /inquiries) and Google Maps / review links.
class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key, this.topic});
  final String? topic;

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: ref.read(sessionProvider)?.name);
  late final _email = TextEditingController(text: ref.read(sessionProvider)?.email);
  late final _phone = TextEditingController(text: ref.read(sessionProvider)?.phone);
  final _message = TextEditingController();
  late String _topic = contactTopics.any((t) => t.$1 == widget.topic) ? widget.topic! : 'order';
  bool _sending = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      final msg = await ref
          .read(supportRepositoryProvider)
          .sendInquiry(name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim(), topic: _topic, message: _message.text.trim());
      _message.clear();
      if (mounted) showToast(context, msg);
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget quick(IconData icon, String label, Color color, VoidCallback onTap) => Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppText.sans(size: 12, weight: FontWeight.w700)),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      bottomNavigationBar: StickyBar(
        child: ElevatedButton.icon(
          onPressed: _sending ? null : _send,
          icon: const Icon(Icons.send_rounded, size: 18),
          label: BusyLabel(busy: _sending, label: 'SEND MESSAGE'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                quick(Icons.chat_outlined, 'WhatsApp', const Color(0xFF128C7E), Launcher.whatsapp),
                const SizedBox(width: 8),
                quick(Icons.call_outlined, 'Call', AppColors.terracotta, Launcher.call),
                const SizedBox(width: 8),
                quick(Icons.mail_outline_rounded, 'Email', const Color(0xFF2563EB), Launcher.email),
                const SizedBox(width: 8),
                quick(Icons.support_agent_rounded, 'Chat', AppColors.cocoa, () => context.push('/chat')),
              ],
            ),
          ),
          SectionCard(
            title: 'Send us a message',
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Order help, bulk gifting, custom hampers or a scent recommendation — we reply within a day.', style: AppText.muted(size: 12.5)),
                  const SizedBox(height: 14),
                  Text('Topic', style: AppText.sans(size: 13, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (v, l) in contactTopics)
                        ChoiceChip(label: Text(l), selected: _topic == v, showCheckmark: false, onSelected: (_) => setState(() => _topic = v)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                    validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                    validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v?.trim() ?? '') ? null : 'Please enter a valid email',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: 'Phone (optional)',
                      prefixText: '+91 ',
                      prefixIcon: Icon(Icons.phone_outlined),
                      counterText: '',
                    ),
                    validator: (v) => (v == null || v.isEmpty || RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) ? null : 'Enter a 10-digit mobile number',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _message,
                    maxLines: 5,
                    minLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Your message', alignLabelWithHint: true),
                    validator: (v) => (v?.trim().length ?? 0) < 10 ? 'Please write at least 10 characters' : null,
                  ),
                ],
              ),
            ),
          ),
          SectionCard(
            title: 'Find us on Google',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loved your candle? A quick Google review helps our small, handmade studio. It takes 30 seconds.', style: AppText.muted(size: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(onPressed: Launcher.maps, icon: const Icon(Icons.map_outlined, size: 18), label: const Text('MAPS')),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(onPressed: Launcher.review, icon: const Icon(Icons.star_rounded, size: 18), label: const Text('REVIEW')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 8), child: ContactLinks()),
        ],
      ),
    );
  }
}
