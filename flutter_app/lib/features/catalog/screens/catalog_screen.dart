// lib/features/catalog/screens/catalog_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';
import '../widgets/product_card.dart';
import '../widgets/filter_bar.dart';

// Mock data — заменить на Riverpod + API
final _mockProducts = List.generate(12, (i) => Product(
  id: 'p$i',
  sku: 'SKU-${100 + i}',
  name: ['Oak Nordic', 'Walnut Milano', 'Ash Provence', 'Pine Scandi',
         'Teak Java', 'Cherry Classic', 'Birch Loft', 'Wenge Dark',
         'Maple Boston', 'Bamboo Zen', 'Mahogany Royal', 'Cedar Natural'][i % 12],
  brand: ['Barlinek', 'Tarkett', 'Quick-Step', 'Pergo'][i % 4],
  collection: 'Premium ${2024 + i % 2}',
  categoryId: i < 8 ? 'parquet' : 'panels',
  colorName: ['Natural Oak', 'Dark Walnut', 'Light Ash', 'Pine Grey'][i % 4],
  colorHex: ['#D6B48A', '#8B5E3C', '#E8D8C4', '#B8A898'][i % 4],
  thicknessMm: [8.0, 10.0, 12.0, 14.0][i % 4],
  wearClass: ['AC3', 'AC4', 'AC5'][i % 3],
  moistureResistant: i % 2 == 0,
  installType: ['lock', 'glue', 'floating', 'glue_lock'][i % 4],
  floorHeatCompat: i % 3 != 0,
  pricePerM2: 55 + (i * 8).toDouble(),
  vatRate: 18,
  photoUrls: ['https://picsum.photos/seed/${i + 10}/400/300'],
  textureUrl: 'https://picsum.photos/seed/${i + 20}/256/256',
  stockQty: 200 + i * 15,
  reservedQty: 10,
  isActive: true,
  isFeatured: i < 3,
));

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _search = TextEditingController();
  String _selectedCategory = 'all';
  bool? _filterHeat;
  bool? _filterMoisture;

  List<Product> get _filtered {
    return _mockProducts.where((p) {
      if (_selectedCategory != 'all' && p.categoryId != _selectedCategory) return false;
      if (_filterHeat == true && !p.floorHeatCompat) return false;
      if (_filterMoisture == true && !p.moistureResistant) return false;
      if (_search.text.isNotEmpty &&
          !p.name.toLowerCase().contains(_search.text.toLowerCase()) &&
          !p.brand.toLowerCase().contains(_search.text.toLowerCase())) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
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
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Поиск: бренд, коллекция, цвет...',
                    prefixIcon: Icon(Icons.search, color: AppColors.oak),
                    filled: true,
                    fillColor: AppColors.sand,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FilterBar(
              selectedCategory: _selectedCategory,
              filterHeat: _filterHeat,
              filterMoisture: _filterMoisture,
              onCategoryChanged: (c) => setState(() => _selectedCategory = c),
              onHeatChanged: (v) => setState(() => _filterHeat = v),
              onMoistureChanged: (v) => setState(() => _filterMoisture = v),
            ),
          ),
        ],
        body: _filtered.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('Ничего не найдено', style: t.bodyMedium?.copyWith(color: AppColors.textHint)),
                ]))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) => ProductCard(
                  product: _filtered[i],
                  onTap: () => ctx.push('/catalog/${_filtered[i].id}'),
                  onAr: () => ctx.push('/ar', extra: _filtered[i].id),
                ),
              ),
      ),
    );
  }
}
