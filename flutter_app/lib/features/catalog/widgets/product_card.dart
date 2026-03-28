// lib/features/catalog/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAr;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAr,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.sandDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.network(
                      product.photoUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.sand,
                        child: const Icon(Icons.texture, color: AppColors.oak, size: 32),
                      ),
                    ),
                  ),
                  if (product.isFeatured)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.moss,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text('НОВИНКА',
                          style: t.labelSmall?.copyWith(color: AppColors.cream, letterSpacing: 1)),
                      ),
                    ),
                  Positioned(
                    bottom: 8, right: 8,
                    child: GestureDetector(
                      onTap: onAr,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.walnut,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.view_in_ar_rounded, size: 18, color: AppColors.cream),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand,
                    style: t.labelSmall?.copyWith(color: AppColors.textHint),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(product.name,
                    style: t.titleMedium,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text('₪${product.pricePerM2.toStringAsFixed(0)}',
                      style: t.titleMedium?.copyWith(
                        color: AppColors.walnut, fontWeight: FontWeight.w600)),
                    Text(' /м²', style: t.bodySmall),
                    const Spacer(),
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: product.colorHex != null
                            ? _hexColor(product.colorHex!)
                            : AppColors.oak,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.sandDark),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.oak;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// lib/features/catalog/widgets/filter_bar.dart
