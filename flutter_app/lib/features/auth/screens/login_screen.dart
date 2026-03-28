// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  void _sendOtp() async {
    if (_phoneCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // TODO: Firebase Auth OTP
    setState(() => _loading = false);
    if (mounted) context.push(AppRoutes.otp, extra: _phoneCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Logo
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.walnut,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.forest_rounded, color: AppColors.cream, size: 22),
                ),
                const SizedBox(width: 12),
                Text('Wild House', style: t.displaySmall?.copyWith(color: AppColors.walnut)),
              ]),
              const SizedBox(height: 12),
              Text(
                'AR-примерка\nпаркета и облицовки',
                style: t.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              const Spacer(),

              // Phone input
              Text('Номер телефона', style: t.labelLarge?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _sendOtp(),
                decoration: const InputDecoration(
                  hintText: '+972 50 000 0000',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.oak),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _sendOtp,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cream))
                      : const Text('ПОЛУЧИТЬ КОД'),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Первая AR-сессия — бесплатно',
                  style: t.bodySmall?.copyWith(color: AppColors.moss),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
