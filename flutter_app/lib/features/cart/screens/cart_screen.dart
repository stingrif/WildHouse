import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    
    final currencyType = ref.watch(currencyProvider);
    final currencyFormatter = ref.read(currencyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.cartTitle),
        actions: [
          // Кнопка смены локализации (Ручной тумблер)
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.walnut, size: 20),
            onPressed: () {
              final currentLabel = ref.read(localeProvider).languageCode;
              final next = currentLabel == 'ru' ? 'en' : (currentLabel == 'en' ? 'he' : 'ru');
              ref.read(localeProvider.notifier).setLocale(Locale(next));
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.currency_exchange, color: AppColors.walnut, size: 18),
            label: Text(currencyType == AppCurrency.ils ? '₪ ILS' : '\$ USD', style: const TextStyle(color: AppColors.walnut)),
            onPressed: () => ref.read(currencyProvider.notifier).toggle(),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (cartItems.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(loc.cartEmpty))),
            
          ...cartItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _CartItem(
                name: item.name,
                brand: item.brand,
                area: item.area,
                pricePerM2: item.pricePerM2,
                installIncluded: item.installIncluded,
                installPrice: item.installPrice,
                onRemove: () => cartNotifier.removeFromCart(item.id),
              ),
          )),
          const SizedBox(height: 16),
          // Promo code
          TextField(
            decoration: InputDecoration(
              hintText: loc.promoCode,
              suffixIcon: TextButton(
                onPressed: () {},
                child: Text(loc.applyPromo),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.sandDark),
            ),
            child: Column(children: [
              _SummaryRow(loc.materialLbl, currencyFormatter.format(cartNotifier.materialSubtotal)),
              _SummaryRow(loc.installLbl, currencyFormatter.format(cartNotifier.installSubtotal)),
              _SummaryRow('${loc.vatLbl} 18%', currencyFormatter.format(cartNotifier.vat)),
              const Divider(height: 16),
              Row(children: [
                Text(loc.totalLbl, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(currencyFormatter.format(cartNotifier.total), style: t.headlineSmall?.copyWith(color: AppColors.walnut)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.order),
            child: Text(loc.checkoutBtn),
          ),
        ],
      ),
    );
  }
}

class _CartItem extends ConsumerWidget {
  final String name, brand;
  final double area, pricePerM2;
  final bool installIncluded;
  final double installPrice;
  final VoidCallback onRemove;

  const _CartItem({
    required this.name, required this.brand, required this.area,
    required this.pricePerM2, required this.installIncluded,
    required this.installPrice, required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final currencyFormatter = ref.read(currencyProvider.notifier);
    
    final total = area * pricePerM2 * 1.18 + (installIncluded ? installPrice : 0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.sandDark),
      ),
      child: Row(children: [
        Container(width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.sand, borderRadius: BorderRadius.circular(4)),
          child: const Icon(Icons.texture, color: AppColors.oak)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: t.titleMedium),
          Text(brand, style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
          Text('${area.toStringAsFixed(1)} м²  •  ${currencyFormatter.format(pricePerM2)}/м²',
            style: t.bodySmall),
          if (installIncluded)
            Text('+ ${loc.installLbl} ${currencyFormatter.format(installPrice)}',
              style: t.bodySmall?.copyWith(color: AppColors.moss)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onRemove,
            color: AppColors.textHint),
          Text(currencyFormatter.format(total),
            style: t.titleMedium?.copyWith(color: AppColors.walnut, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(label, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: t.bodyMedium),
      ]),
    );
  }
}
