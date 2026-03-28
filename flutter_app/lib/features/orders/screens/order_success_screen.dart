// lib/features/orders/screens/order_success_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.moss.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 52, color: AppColors.moss),
              ),
              const SizedBox(height: 24),
              Text('Заказ оформлен!',
                style: t.displaySmall?.copyWith(color: AppColors.walnut),
                textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Мы свяжемся с вами для подтверждения даты монтажа. '
                'Детали отправлены на ваш номер телефона.',
                style: t.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Order number mock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.receipt_long_outlined, color: AppColors.oak, size: 20),
                  const SizedBox(width: 10),
                  Text('Заказ #WH-2026-0001',
                    style: t.titleMedium?.copyWith(color: AppColors.walnut)),
                ]),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.catalog),
                  child: const Text('В КАТАЛОГ'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.profile),
                  child: const Text('МОИ ЗАКАЗЫ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
