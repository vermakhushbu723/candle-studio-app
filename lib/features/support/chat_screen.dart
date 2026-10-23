import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/content/chatbot_content.dart';
import '../../services/launcher.dart';
import '../../state/catalog_provider.dart';
import '../../state/repositories.dart';
import '../../state/session_provider.dart';
import '../../widgets/app_image.dart';
import '../../widgets/common.dart';

class _Msg {
  _Msg.user(this.text) : fromBot = false, actions = const [], products = const [], quickReplies = const [];
  _Msg.bot(this.text, {this.actions = const [], this.products = const [], this.quickReplies = const []}) : fromBot = true;

  final bool fromBot;
  final String text;
  final List<BotAction> actions;
  final List<String> products;
  final List<String> quickReplies;
}

/// "Diya" — the rule-based support assistant. "Leave a message" creates a callback ticket (POST /tickets).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[_Msg.bot(botGreeting, quickReplies: botQuickReplies)];
  bool _typing = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent + 200, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    _input.clear();
    setState(() {
      _messages.add(_Msg.user(t));
      _typing = true;
    });
    _toBottom();
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    final intent = botReply(t);
    final shipping = ref.read(shippingProvider);
    setState(() {
      _typing = false;
      _messages.add(_Msg.bot(shipping.fill(intent.text), actions: intent.actions, products: intent.products));
    });
    _toBottom();
  }

  void _runAction(BotAction a) {
    switch (a.type) {
      case BotActionType.route:
        a.route!.startsWith('/shop') ? context.go(a.route!) : context.push(a.route!);
      case BotActionType.whatsapp:
        Launcher.whatsapp();
      case BotActionType.call:
        Launcher.call();
      case BotActionType.inquiry:
        _openTicketForm(a.topic ?? 'Support');
    }
  }

  Future<void> _openTicketForm(String topic) async {
    final ticketId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TicketForm(topic: topic),
    );
    if (ticketId == null || !mounted) return;
    setState(() => _messages.add(_Msg.bot('Thanks! Your request $ticketId is with our team — we’ll call you back within 24 hours.')));
    _toBottom();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.charcoal,
              child: Icon(Icons.local_fire_department_rounded, color: AppColors.caramel, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diya', style: AppText.sans(size: 16, weight: FontWeight.w700)),
                Row(
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: AppColors.success),
                    const SizedBox(width: 5),
                    Text('Candle assistant · online', style: AppText.muted(size: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: Launcher.call, tooltip: 'Call us'),
          IconButton(
            icon: const Icon(Icons.chat_rounded, color: AppColors.whatsapp),
            onPressed: Launcher.whatsapp,
            tooltip: 'WhatsApp',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) return const _Bubble(fromBot: true, child: Text('…'));
                final m = _messages[i];
                final products = [for (final id in m.products) ?catalog?.product(id)];
                return Column(
                  crossAxisAlignment: m.fromBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    _Bubble(
                      fromBot: m.fromBot,
                      child: Text(m.text, style: AppText.sans(size: 14, color: m.fromBot ? AppColors.charcoal : Colors.white)),
                    ),
                    for (final p in products)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, right: 40),
                        child: AppCard(
                          padding: const EdgeInsets.all(8),
                          radius: 14,
                          onTap: () => context.push('/product/${p.id}'),
                          child: Row(
                            children: [
                              AppImage(p.image, width: 52, height: 52, radius: 10),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.sans(size: 13, weight: FontWeight.w600),
                                ),
                              ),
                              Text(formatPrice(p.price), style: AppText.sans(size: 13, weight: FontWeight.w800)),
                              const SizedBox(width: 6),
                            ],
                          ),
                        ),
                      ),
                    if (m.actions.isNotEmpty || m.quickReplies.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final a in m.actions)
                              ActionChip(
                                avatar: Icon(
                                  switch (a.type) {
                                    BotActionType.whatsapp => Icons.chat_rounded,
                                    BotActionType.call => Icons.call_rounded,
                                    BotActionType.inquiry => Icons.edit_note_rounded,
                                    BotActionType.route => Icons.arrow_forward_rounded,
                                  },
                                  size: 16,
                                  color: AppColors.terracotta,
                                ),
                                label: Text(a.label),
                                onPressed: () => _runAction(a),
                              ),
                            for (final q in m.quickReplies) ActionChip(label: Text(q), onPressed: () => _send(q)),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.linen)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: const InputDecoration(hintText: 'Type your question…', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    onPressed: () => _send(_input.text),
                    style: IconButton.styleFrom(backgroundColor: AppColors.terracotta),
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.fromBot, required this.child});
  final bool fromBot;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8, left: fromBot ? 0 : 50, right: fromBot ? 50 : 0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: fromBot ? Colors.white : AppColors.terracotta,
      border: fromBot ? Border.all(color: AppColors.linen) : null,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(18),
        bottomLeft: Radius.circular(fromBot ? 4 : 18),
        bottomRight: Radius.circular(fromBot ? 18 : 4),
      ),
    ),
    child: child,
  );
}

/// Name, mobile, topic and message → callback ticket.
class _TicketForm extends ConsumerStatefulWidget {
  const _TicketForm({required this.topic});
  final String topic;

  @override
  ConsumerState<_TicketForm> createState() => _TicketFormState();
}

class _TicketFormState extends ConsumerState<_TicketForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: ref.read(sessionProvider)?.name);
  late final _phone = TextEditingController(text: ref.read(sessionProvider)?.phone);
  final _message = TextEditingController();
  late String _topic = inquiryTopics.contains(widget.topic) ? widget.topic : inquiryTopics.first;
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final id = await ref
          .read(supportRepositoryProvider)
          .createTicket(name: _name.text.trim(), phone: _phone.text.trim(), topic: _topic, message: _message.text.trim());
      if (mounted) Navigator.pop(context, id);
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Leave a message', style: AppText.serif(size: 22)),
            Text('Our team will call you back within 24 hours.', style: AppText.muted()),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'Mobile', prefixText: '+91 ', counterText: ''),
              validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch(v?.trim() ?? '') ? null : '10-digit mobile number',
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _topic,
              decoration: const InputDecoration(labelText: 'Topic'),
              items: [for (final t in inquiryTopics) DropdownMenuItem(value: t, child: Text(t))],
              onChanged: (v) => setState(() => _topic = v ?? _topic),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _message,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message'),
              validator: (v) => (v?.trim().length ?? 0) < 5 ? 'Tell us a bit more' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sending ? null : _submit,
              child: _sending
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : const Text('Request a callback'),
            ),
          ],
        ),
      ),
    );
  }
}
