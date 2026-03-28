// lib/features/auth/screens/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/app_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String verificationId;
  
  const OtpScreen({super.key, required this.phone, required this.verificationId});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes  = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitEntered(int idx, String val) {
    if (val.isNotEmpty && idx < 5) {
      _focusNodes[idx + 1].requestFocus();
    }
    if (_code.length == 6) _verify();
  }

  void _verify() async {
    setState(() { _loading = true; _error = null; });
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _code,
      );
      
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Update global auth state on success
      ref.read(authProvider.notifier).state = true;
      
      setState(() => _loading = false);
      if (mounted) context.go(AppRoutes.catalog);
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message ?? 'Неверный СМС-код';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Непредвиденная ошибка';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Подтверждение')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Введите код', style: t.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Отправлен на ${widget.phone}',
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),

            // 6-digit OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => SizedBox(
                width: 46,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: t.headlineLarge?.copyWith(color: AppColors.walnut),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: AppColors.sand,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.walnut, width: 2),
                    ),
                  ),
                  onChanged: (v) => _onDigitEntered(i, v),
                ),
              )),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: t.bodySmall?.copyWith(color: AppColors.error)),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_loading || _code.length < 6) ? null : _verify,
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cream))
                    : const Text('ВОЙТИ'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SMS отправлено повторно (Дэмо)')));
                },
                child: const Text('Отправить снова'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
