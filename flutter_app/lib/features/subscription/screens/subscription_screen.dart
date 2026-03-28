// lib/features/subscription/screens/subscription_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/models.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionPlan _selected = SubscriptionPlan.standard;
  bool _loading = false;

  static const _features = {
    SubscriptionPlan.basic: [
      '5 AR-сессий в неделю',
      'Калькулятор площади',
      'Каталог материалов',
      'Поддержка по email',
    ],
    SubscriptionPlan.standard: [
      'Безлимитные AR-сессии',
      'AI-замер площади',
      'Сохранение проектов',
      'Сравнение материалов',
      'Приоритетная поддержка',
    ],
    SubscriptionPlan.pro: [
      'Всё из Standard',
      'Несколько помещений',
      'Экспорт PDF-отчёта',
      'B2B-доступ (дизайнеры)',
      'Персональный менеджер',
      'Скидка 10% на материалы',
    ],
  };

  void _subscribe() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2)); // TODO: Stripe / Tranzila
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Подписка ${_selected.label} активирована!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Подписка')),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Text('Выберите план', style: t.displaySmall),
          const SizedBox(height: 4),
          Text(
            'Первая AR-сессия — бесплатно для всех.',
            style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Plan cards
          ...SubscriptionPlan.values.map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PlanCard(
              plan: plan,
              features: _features[plan]!,
              isSelected: _selected == plan,
              isPopular: plan == SubscriptionPlan.standard,
              onTap: () => setState(() => _selected = plan),
            ),
          )),

          const SizedBox(height: 8),

          // Token discount info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.oakLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.oak.withOpacity(0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.toll_rounded, color: AppColors.walnut),
              const SizedBox(width: 12),
              Expanded(child: Text(
                'Оплата токеном Wild House даёт скидку 15% на все материалы.',
                style: t.bodySmall?.copyWith(color: AppColors.walnut),
              )),
            ]),
          ),

          const SizedBox(height: 24),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _subscribe,
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cream))
                  : Text(
                      'ПОДКЛЮЧИТЬ ${_selected.label.toUpperCase()} — '
                      '₪${_selected.price.toStringAsFixed(0)} / ${_selected.period}'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Отменить можно в любой момент',
              style: t.bodySmall?.copyWith(color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final List<String> features;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan, required this.features, required this.isSelected,
    required this.isPopular, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.walnutDark : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.walnut : AppColors.sandDark,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.walnut.withOpacity(0.15),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              Text(plan.label,
                style: t.headlineSmall?.copyWith(
                  color: isSelected ? AppColors.cream : AppColors.walnut)),
              const SizedBox(width: 8),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.oak,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text('ПОПУЛЯРНЫЙ',
                    style: t.labelSmall?.copyWith(color: AppColors.surface, fontSize: 9)),
                ),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₪${plan.price.toStringAsFixed(0)}',
                  style: t.headlineMedium?.copyWith(
                    color: isSelected ? AppColors.oak : AppColors.walnut,
                    fontWeight: FontWeight.w700)),
                Text('/ ${plan.period}',
                  style: t.bodySmall?.copyWith(
                    color: isSelected ? AppColors.cream.withOpacity(0.7) : AppColors.textSecondary)),
              ]),
            ]),
          ),

          // Divider
          Divider(height: 1,
            color: isSelected ? AppColors.walnut.withOpacity(0.4) : AppColors.sandDark),

          // Features
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Icon(Icons.check_rounded, size: 16,
                    color: isSelected ? AppColors.oak : AppColors.moss),
                  const SizedBox(width: 8),
                  Text(f, style: t.bodySmall?.copyWith(
                    color: isSelected ? AppColors.cream.withOpacity(0.9) : AppColors.textPrimary)),
                ]),
              )).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
