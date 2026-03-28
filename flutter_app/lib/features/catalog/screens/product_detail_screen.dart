import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/catalog_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final currencyType = ref.watch(currencyProvider);
    final currencyFormatter = ref.read(currencyProvider.notifier);
    
    final asyncProduct = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: asyncProduct.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.walnut)),
        error: (err, stack) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Не удалось загрузить товар', style: t.titleMedium),
            TextButton(
              onPressed: () => ref.refresh(productDetailProvider(productId)), 
              child: const Text('Повторить')
            ),
          ])
        ),
        data: (product) => CustomScrollView(
          slivers: [
            // Hero image app bar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              actions: [
                Container(
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: TextButton.icon(
                    icon: const Icon(Icons.currency_exchange, color: Colors.white, size: 18),
                    label: Text(currencyType == AppCurrency.ils ? '₪ ILS' : '\$ USD', style: const TextStyle(color: Colors.white)),
                    onPressed: () => ref.read(currencyProvider.notifier).toggle(),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  product.photoUrls.isNotEmpty ? product.photoUrls.first : 'https://picsum.photos/400',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.brand.toUpperCase(),
                      style: t.labelMedium?.copyWith(color: AppColors.oak, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(product.name, style: t.displaySmall),
                    Text(product.collection,
                      style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),

                    const SizedBox(height: 20),

                    Row(children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${currencyFormatter.format(product.pricePerM2)} /м²',
                          style: t.headlineLarge?.copyWith(color: AppColors.walnut)),
                        Text('+ НДС 18%  =  ${currencyFormatter.format(product.priceWithVat)}',
                          style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      ]),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: product.availableQty > 50
                              ? AppColors.moss.withOpacity(0.15)
                              : AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.availableQty.toStringAsFixed(0)} м² в наличии',
                          style: t.labelSmall?.copyWith(
                            color: product.availableQty > 50
                                ? AppColors.moss : AppColors.warning),
                        ),
                      ),
                    ]),

                    const Divider(height: 32),

                    Text('Характеристики', style: t.titleLarge),
                    const SizedBox(height: 12),
                    _Spec('Толщина', '${product.thicknessMm} мм'),
                    _Spec('Класс истирания', product.wearClass),
                    _Spec('Монтаж', _installLabel(product.installType)),
                    _Spec('Влагостойкость', product.moistureResistant ? 'Да' : 'Нет'),
                    _Spec('Тёплый пол', product.floorHeatCompat ? 'Совместим' : 'Не совместим'),
                    _Spec('Цвет', product.colorName),

                    const Divider(height: 32),

                    Text('Текстура', style: t.titleLarge),
                    const SizedBox(height: 12),
                    if (product.textureUrl.isNotEmpty) 
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.textureUrl,
                          height: 80, width: 80, fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: asyncProduct.maybeWhen(
        data: (product) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.view_in_ar_rounded),
                label: const Text('AR'),
                onPressed: () => context.push(AppRoutes.ar, extra: product.id),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('РАССЧИТАТЬ'),
                  onPressed: () => context.push(AppRoutes.calculator),
                ),
              ),
            ]),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  String _installLabel(String type) {
    switch (type) {
      case 'lock':      return 'Замковый';
      case 'glue':      return 'На клей';
      case 'glue_lock': return 'Клей + замок';
      case 'floating':  return 'Плавающий';
      default:          return type;
    }
  }
}

class _Spec extends StatelessWidget {
  final String label;
  final String value;
  const _Spec(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(label, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
