import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../widgets/product_card.dart';
import '../widgets/filter_bar.dart';
import '../../../core/providers/catalog_provider.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _updateFilter({String? categoryId, bool? heat, bool? moisture, String? search}) {
    final cur = ref.read(catalogFilterProvider);
    ref.read(catalogFilterProvider.notifier).state = CatalogFilter(
       categoryId: categoryId ?? cur.categoryId,
       filterHeat: heat ?? cur.filterHeat,
       filterMoisture: moisture ?? cur.filterMoisture,
       searchQuery: search ?? cur.searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final curFilter = ref.watch(catalogFilterProvider);
    final productsAsync = ref.watch(catalogListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            title: const Text('Wild House'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _search,
                  onSubmitted: (val) => _updateFilter(search: val),
                  decoration: InputDecoration(
                    hintText: 'Поиск: бренд, коллекция, цвет...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.oak),
                    suffixIcon: IconButton(
                       icon: const Icon(Icons.clear, size: 18),
                       onPressed: () {
                         _search.clear();
                         _updateFilter(search: '');
                       },
                    ),
                    filled: true,
                    fillColor: AppColors.sand,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FilterBar(
              selectedCategory: curFilter.categoryId,
              filterHeat: curFilter.filterHeat,
              filterMoisture: curFilter.filterMoisture,
              onCategoryChanged: (c) => _updateFilter(categoryId: c),
              onHeatChanged: (v) => _updateFilter(heat: v),
              onMoistureChanged: (v) => _updateFilter(moisture: v),
            ),
          ),
        ],
        body: productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.walnut)),
          error: (err, stack) => Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Ошибка сети', style: t.titleMedium),
              Text(err.toString(), textAlign: TextAlign.center, style: t.bodySmall?.copyWith(color: AppColors.textSecondary)),
              TextButton(onPressed: () => ref.refresh(catalogListProvider), child: const Text('Повторить')),
            ])
          ),
          data: (products) {
            if (products.isEmpty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('Ничего не найдено', style: t.bodyMedium?.copyWith(color: AppColors.textHint)),
                ])
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (ctx, i) => ProductCard(
                product: products[i],
                onTap: () => ctx.push('/catalog/${products[i].id}'),
                onAr: () => ctx.push('/ar', extra: products[i].id),
              ),
            );
          },
        ),
      ),
    );
  }
}
