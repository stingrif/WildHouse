// lib/features/orders/screens/order_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/catalog_provider.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});
  @override 
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final _addressCtrl = TextEditingController();
  DateTime? _installDate;
  String _paymentMethod = 'card';
  bool _loading = false;

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (d != null) setState(() => _installDate = d);
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;
    if (_addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите адрес')));
      return;
    }

    setState(() => _loading = true);

    try {
      final dio = ref.read(dioProvider);

      // 1. Create order on backend
      final lines = cart.map((c) => {
        'productId': c.id, 
        'areaM2': c.area, 
        'includeInstallation': c.installIncluded
      }).toList();

      final orderRes = await dio.post('orders', data: {
        'lines': lines,
        'address': _addressCtrl.text,
        'installDate': _installDate?.toIso8601String(),
        'paymentMethod': _paymentMethod
      });
      final orderId = orderRes.data['id'];

      // 2. Crypto bypass vs Stripe processing
      if (_paymentMethod == 'crypto') {
        // Handle Crypto 
        ref.read(cartProvider.notifier).clearCart();
        if (mounted) context.go(AppRoutes.orderSuccess);
        return;
      }

      // 3. Obtain Stripe Payment Intent
      final intentRes = await dio.post('orders/$orderId/payment-intent');
      final clientSecret = intentRes.data['clientSecret'];
      final pubKey = intentRes.data['publishableKey'];

      Stripe.publishableKey = pubKey;

      // 4. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Wild House',
          style: ThemeMode.light,
        ),
      );

      // 5. Present Sheet to user
      await Stripe.instance.presentPaymentSheet();

      // 6. Success
      ref.read(cartProvider.notifier).clearCart();
      if (mounted) context.go(AppRoutes.orderSuccess);

    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Оплата отменена: ${e.error.message}')));
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка сервера: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Оформление заказа')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Адрес установки', style: t.titleLarge),
          const SizedBox(height: 8),
          TextField(controller: _addressCtrl,
            decoration: const InputDecoration(
              hintText: 'ул. Герцль, 12, Тель-Авив',
              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.oak),
            )),

          const SizedBox(height: 24),
          Text('Дата монтажа', style: t.titleLarge),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.sand,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.sandDark),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined, color: AppColors.oak, size: 20),
                const SizedBox(width: 12),
                Text(
                  _installDate == null
                      ? 'Выбрать дату'
                      : '${_installDate!.day}.${_installDate!.month}.${_installDate!.year}',
                  style: t.bodyMedium?.copyWith(
                    color: _installDate == null ? AppColors.textHint : AppColors.textPrimary,
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 24),
          Text('Способ оплаты', style: t.titleLarge),
          const SizedBox(height: 8),
          _PaymentOption(
            icon: Icons.credit_card_rounded,
            label: 'Банковская карта',
            subtitle: 'Visa / Mastercard / Apple Pay',
            value: 'card',
            selected: _paymentMethod,
            onTap: () => setState(() => _paymentMethod = 'card'),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            icon: Icons.currency_bitcoin_rounded,
            label: 'Криптовалюта (TON)',
            subtitle: 'Скидка 15% на материал',
            value: 'crypto',
            selected: _paymentMethod,
            onTap: () => setState(() => _paymentMethod = 'crypto'),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loading ? null : _placeOrder,
            child: _loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cream))
                : const Text('ПОДТВЕРДИТЬ И ОПЛАТИТЬ'),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label, subtitle, value, selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon, required this.label, required this.subtitle,
    required this.value, required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.oakLight : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.oak : AppColors.sandDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Icon(icon, color: isSelected ? AppColors.walnut : AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: t.titleMedium?.copyWith(
              color: isSelected ? AppColors.walnut : AppColors.textPrimary)),
            Text(subtitle, style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ])),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: AppColors.walnut),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// lib/features/orders/screens/order_success_screen.dart

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
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.moss.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 52, color: AppColors.moss),
              ),
              const SizedBox(height: 24),
              Text('Заказ оформлен!', style: t.displaySmall?.copyWith(color: AppColors.walnut)),
              const SizedBox(height: 12),
              Text(
                'Мы свяжемся с вами для подтверждения даты монтажа.',
                style: t.bodyMedium?.copyWith(
                  color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.catalog),
                child: const Text('В КАТАЛОГ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
