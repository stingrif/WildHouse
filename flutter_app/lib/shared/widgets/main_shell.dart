// lib/shared/widgets/main_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.ar))           return 1;
    if (location.startsWith(AppRoutes.calculator))   return 2;
    if (location.startsWith(AppRoutes.cart))         return 3;
    if (location.startsWith(AppRoutes.profile))      return 4;
    return 0; // catalog
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.sandDark)),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) {
            switch (i) {
              case 0: context.go(AppRoutes.catalog);
              case 1: context.go(AppRoutes.ar);
              case 2: context.go(AppRoutes.calculator);
              case 3: context.go(AppRoutes.cart);
              case 4: context.go(AppRoutes.profile);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Каталог',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_in_ar_outlined),
              activeIcon: Icon(Icons.view_in_ar_rounded),
              label: 'AR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate_rounded),
              label: 'Расчёт',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Корзина',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
