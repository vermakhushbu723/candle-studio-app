import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user.dart';
import '../../../services/google_auth_service.dart';
import '../../../state/repositories.dart';
import '../../../widgets/common.dart';
import 'otp_input.dart';

/// Passwordless sign-in: mobile number → 6-digit OTP (→ name for a new account), or Google.
class PhoneOtpLogin extends ConsumerStatefulWidget {
  const PhoneOtpLogin({super.key, required this.onSignedIn});
  final ValueChanged<AppUser> onSignedIn;

  @override
  ConsumerState<PhoneOtpLogin> createState() => _PhoneOtpLoginState();
}

class _PhoneOtpLoginState extends ConsumerState<PhoneOtpLogin> {
  static const _resendSeconds = 30;

  final _phoneForm = GlobalKey<FormState>();
  final _otpForm = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();

  bool _otpStep = false;
  bool _agree = true;
  bool _isNewUser = false;
  String? _devOtp;
  bool _loading = false;
  bool _googleLoading = false;
  int _wait = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_phone, _otp, _name, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _wait = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_wait <= 1) t.cancel();
      if (mounted) setState(() => _wait--);
    });
  }

  Future<void> _sendOtp() async {
    if (!_otpStep && !_phoneForm.currentState!.validate()) return;
    if (!_agree) return showToast(context, 'Please accept the Terms and Privacy Policy', error: true);
    setState(() => _loading = true);
    try {
      final r = await ref.read(authRepositoryProvider).sendOtp(_phone.text.trim());
      if (!mounted) return;
      setState(() {
        _isNewUser = r.isNewUser;
        _devOtp = r.devOtp;
        _otpStep = true;
        _otp.clear();
      });
      _startTimer();
      showToast(context, r.message);
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    if (_loading) return; // the OTP boxes and the button can both trigger this
    if (!_otpForm.currentState!.validate()) return;
    if (_otp.text.length != 6) return showToast(context, 'Enter the 6-digit OTP', error: true);
    setState(() => _loading = true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .verifyOtp(phone: _phone.text.trim(), otp: _otp.text, name: _isNewUser ? _name.text.trim() : null, email: _isNewUser ? _email.text.trim() : null);
      widget.onSignedIn(user);
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    try {
      final token = await GoogleAuthService().idToken();
      widget.onSignedIn(await ref.read(authRepositoryProvider).google(token));
    } on GoogleSignInCancelled {
      // closed the account picker
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } catch (e) {
      if (mounted) showToast(context, 'Google sign-in isn’t available right now. Please use your mobile number.', error: true);
      debugPrint('[google] $e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: _otpStep ? _otpView() : _phoneView()),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('or', style: AppText.muted()),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: _googleLoading ? null : _google,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.charcoal,
            side: const BorderSide(color: AppColors.linen),
          ),
          child: _googleLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _GoogleG(),
                    const SizedBox(width: 10),
                    Text('Continue with Google', style: AppText.sans(size: 15, weight: FontWeight.w600)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _phoneView() {
    return Form(
      key: _phoneForm,
      child: Column(
        key: const ValueKey('phone'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              hintText: '98XXXXXXXX',
              prefixIcon: Icon(Icons.phone_outlined),
              prefixText: '+91 ',
              counterText: '',
            ),
            validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch(v?.trim() ?? '') ? null : 'Enter a 10-digit mobile number',
            onFieldSubmitted: (_) => _sendOtp(),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms',
                        style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () => context.push('/policies/terms'),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () => context.push('/policies/privacy'),
                      ),
                    ],
                  ),
                  style: AppText.sans(size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loading ? null : _sendOtp, child: _loading ? const _Spinner() : const Text('GET OTP')),
        ],
      ),
    );
  }

  Widget _otpView() {
    return Form(
      key: _otpForm,
      child: Column(
        key: const ValueKey('otp'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(_devOtp != null ? 'Your login OTP for ' : 'Enter the 6-digit code sent to ', style: AppText.muted(size: 14)),
              Text('+91 ${_phone.text}', style: AppText.sans(size: 14, weight: FontWeight.w700)),
              TextButton.icon(
                onPressed: () => setState(() => _otpStep = false),
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: const Text('Change'),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
          if (_devOtp != null)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
              decoration: BoxDecoration(
                color: AppColors.sand.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.caramel.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Text('Your OTP is ', style: AppText.sans(size: 14)),
                  Text(
                    _devOtp!,
                    style: AppText.sans(size: 19, weight: FontWeight.w800, color: AppColors.terracotta).copyWith(letterSpacing: 4),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => _otp.text = _devOtp!,
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34), backgroundColor: Colors.white),
                    child: const Text('Fill OTP'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'OTP',
            style: AppText.sans(size: 13, weight: FontWeight.w600, color: AppColors.ash),
          ),
          const SizedBox(height: 6),
          OtpInput(controller: _otp, onCompleted: (_) => _isNewUser ? null : _verify()),
          if (_isNewUser) ...[
            const SizedBox(height: 18),
            Text('New here? Tell us a little about you.', style: AppText.sans(weight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded)),
              validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email (optional)', prefixIcon: Icon(Icons.mail_outline_rounded)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty || RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) ? null : 'Please enter a valid email',
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _loading ? null : _verify,
            child: _loading ? const _Spinner() : Text(_isNewUser ? 'Verify & create account' : 'Verify & log in'),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Didn’t get it? ', style: AppText.muted()),
              _wait > 0
                  ? Text('Resend in ${_wait}s', style: AppText.muted())
                  : TextButton(onPressed: _loading ? null : _sendOtp, child: const Text('Resend OTP')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white));
}

/// Google "G" in brand colours (no extra image asset).
class _GoogleG extends StatelessWidget {
  const _GoogleG();
  @override
  Widget build(BuildContext context) => SizedBox(width: 20, height: 20, child: CustomPaint(painter: _GPainter()));
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height).deflate(2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.2;
    const pi = 3.14159;
    for (final (color, start, sweep) in [
      (const Color(0xFFEA4335), -2.4, 1.55),
      (const Color(0xFFFBBC05), -0.85 - 2.5, -1.6),
      (const Color(0xFF34A853), pi * 0.25, 1.6),
      (const Color(0xFF4285F4), -0.05, 0.85),
    ]) {
      canvas.drawArc(r, start, sweep, false, p..color = color);
    }
    canvas.drawLine(Offset(size.width / 2, size.height / 2), Offset(size.width - 2, size.height / 2), p..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
