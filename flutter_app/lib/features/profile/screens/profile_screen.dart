// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _lang = 'ru';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── User card ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.walnutDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.oak, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded, color: AppColors.surface, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('+972 50 000 0000',
                    style: t.titleLarge?.copyWith(color: AppColors.cream)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.oak.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Standard',
                      style: t.labelSmall?.copyWith(color: AppColors.oak, letterSpacing: 1)),
                  ),
                ],
              )),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.cream, size: 20),
                onPressed: () {},
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Language switcher ────────────────────────────────
          Text('Язык', style: t.titleLarge),
          const SizedBox(height: 10),
          Row(children: [
            _LangChip('RU', 'ru', _lang, (v) => setState(() => _lang = v)),
            const SizedBox(width: 8),
            _LangChip('HE', 'he', _lang, (v) => setState(() => _lang = v)),
            const SizedBox(width: 8),
            _LangChip('EN', 'en', _lang, (v) => setState(() => _lang = v)),
          ]),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // ── Menu items ───────────────────────────────────────
          _MenuItem(
            icon: Icons.receipt_long_outlined,
            label: 'Мои заказы',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.star_border_rounded,
            label: 'Подписка',
            trailing: Text('Standard',
              style: t.labelMedium?.copyWith(color: AppColors.oak)),
            onTap: () => context.push(AppRoutes.subscription),
          ),
          _MenuItem(
            icon: Icons.folder_open_outlined,
            label: 'Мои проекты',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.notifications_none_outlined,
            label: 'Уведомления',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.support_agent_outlined,
            label: 'Поддержка',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.info_outline_rounded,
            label: 'О приложении',
            trailing: Text('v1.0.0',
              style: t.labelSmall?.copyWith(color: AppColors.textHint)),
            onTap: () {},
          ),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          _MenuItem(
            icon: Icons.logout_rounded,
            label: 'Выйти',
            color: AppColors.error,
            onTap: () {
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Выйти?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.login);
                    },
                    child: Text('Выйти',
                      style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ));
            },
          ),

          const SizedBox(height: 32),
          Center(
            child: Text('Wild House © 2026',
              style: t.bodySmall?.copyWith(color: AppColors.textHint)),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;

  const _LangChip(this.label, this.value, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56, height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.walnut : AppColors.sand,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.walnut : AppColors.sandDark),
        ),
        child: Text(label,
          style: TextStyle(
            fontFamily: 'Jost', fontSize: 13, fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.cream : AppColors.textSecondary)),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon, required this.label,
    this.trailing, this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: t.bodyMedium?.copyWith(color: c)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded,
        color: AppColors.textHint, size: 20),
      onTap: onTap,
    );
  }
}
