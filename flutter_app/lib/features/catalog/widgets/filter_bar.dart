// lib/features/catalog/widgets/filter_bar.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FilterBar extends StatelessWidget {
  final String selectedCategory;
  final bool? filterHeat;
  final bool? filterMoisture;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool?> onHeatChanged;
  final ValueChanged<bool?> onMoistureChanged;

  const FilterBar({
    super.key,
    required this.selectedCategory,
    required this.filterHeat,
    required this.filterMoisture,
    required this.onCategoryChanged,
    required this.onHeatChanged,
    required this.onMoistureChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _CategoryChip('Все', 'all', selectedCategory, onCategoryChanged),
          const SizedBox(width: 8),
          _CategoryChip('Паркет', 'parquet', selectedCategory, onCategoryChanged),
          const SizedBox(width: 8),
          _CategoryChip('Панели', 'panels', selectedCategory, onCategoryChanged),
          const SizedBox(width: 8),
          _CategoryChip('Пороги', 'thresholds', selectedCategory, onCategoryChanged),
          const SizedBox(width: 16),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.sandDark),
          const SizedBox(width: 16),
          _ToggleChip(
            label: '🔥 Тёплый пол',
            active: filterHeat == true,
            onTap: () => onHeatChanged(filterHeat == true ? null : true),
          ),
          const SizedBox(width: 8),
          _ToggleChip(
            label: '💧 Влагостойкий',
            active: filterMoisture == true,
            onTap: () => onMoistureChanged(filterMoisture == true ? null : true),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategoryChip(this.label, this.value, this.selected, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.walnut : AppColors.sand,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.walnut : AppColors.sandDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.cream : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.oakLight : AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: active ? AppColors.oak : AppColors.sandDark),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 13,
            color: active ? AppColors.walnut : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
