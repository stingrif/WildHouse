import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../shared/models/models.dart';

// API Base configuration
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    // Для демо используем localhost (на эмуляторе 10.0.2.2)
    baseUrl: 'http://localhost:3000/api/v1/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
});

class CatalogFilter {
  final String categoryId;
  final String searchQuery;
  final bool? filterHeat;
  final bool? filterMoisture;

  const CatalogFilter({
    this.categoryId = 'all',
    this.searchQuery = '',
    this.filterHeat,
    this.filterMoisture,
  });

  Map<String, dynamic> toQuery() {
    final Map<String, dynamic> q = {};
    if (categoryId != 'all') q['categoryId'] = categoryId;
    if (searchQuery.isNotEmpty) q['search'] = searchQuery;
    if (filterHeat == true) q['floorHeatCompat'] = 'true';
    if (filterMoisture == true) q['moistureResistant'] = 'true';
    return q;
  }
}

// Провайдер состояния фильтров
final catalogFilterProvider = StateProvider<CatalogFilter>((ref) => const CatalogFilter());

// Провайдер получения списка товаров с бекенда по фильтру
final catalogListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final filter = ref.watch(catalogFilterProvider);
  final dio = ref.watch(dioProvider);

  try {
    final response = await dio.get('catalog/products', queryParameters: filter.toQuery());
    final data = response.data['items'] as List<dynamic>;
    return data.map((json) => Product.fromJson(json)).toList();
  } catch (e) {
    // Return empty list or throw to surface the error
    throw Exception('Не удалось загрузить каталог. $e');
  }
});

// Провайдер загрузки одного товара по ID (например для AR и Detail Screen)
final productDetailProvider = FutureProvider.family.autoDispose<Product, String>((ref, id) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('catalog/products/$id');
  return Product.fromJson(response.data);
});
