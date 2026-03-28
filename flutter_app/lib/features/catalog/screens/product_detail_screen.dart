// lib/features/catalog/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  // TODO: заменить на Riverpod provider
  Product _findProduct() => Product(
    id: productId, sku: 'SKU-001', name: 'Oak Nordic',
    brand: 'Barlinek', collection: 'Premium 2024',
    categoryId: 'parquet', colorName: 'Natural Oak', colorHex: '#D6B48A',
    thicknessMm: 10, wearClass: 'AC4', moistureResistant: true,
    installType: 'lock', floorHeatCompat: true,
    pricePerM2: 85, vatRate: 18,
    photoUrls: ['https://picsum.photos/seed/42/800/600'],
    textureUrl: 'https://picsum.photos/seed/42/256/256',
    stockQty: 240, reservedQty: 12, isActive: true, isFeatured: true,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = _findProduct();
    final t = Theme.of(context).textTheme;
    final currencyType = ref.watch(currencyProvider);
    final currencyFormatter = ref.read(currencyProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
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
                product.photoUrls.first,
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
                  // Brand + name
                  Text(product.brand.toUpperCase(),
                    style: t.labelMedium?.copyWith(
                      color: AppColors.oak, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text(product.name, style: t.displaySmall),
                  Text(product.collection,
                    style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),

                  const SizedBox(height: 20),

                  // Price
                  Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${currencyFormatter.format(product.pricePerM2)} /м²',
                        style: t.headlineLarge?.copyWith(color: AppColors.walnut)),
                      Text('+ НДС 18%  =  ${currencyFormatter.format(product.priceWithVat)}',
                        style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ]),
                    const Spacer(),
                    // Stock badge
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

                  // Characteristics
                  Text('Характеристики', style: t.titleLarge),
                  const SizedBox(height: 12),
                  _Spec('Толщина', '${product.thicknessMm} мм'),
                  _Spec('Класс истирания', product.wearClass),
                  _Spec('Монтаж', _installLabel(product.installType)),
                  _Spec('Влагостойкость', product.moistureResistant ? 'Да' : 'Нет'),
                  _Spec('Тёплый пол', product.floorHeatCompat ? 'Совместим' : 'Не совместим'),
                  _Spec('Цвет', product.colorName),

                  const Divider(height: 32),

                  // Texture preview
                  Text('Текстура', style: t.titleLarge),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.textureUrl,
                      height: 80, width: 80, fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 100), // space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: SafeArea(
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
