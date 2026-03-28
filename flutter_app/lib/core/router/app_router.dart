// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/catalog/screens/catalog_screen.dart';
import '../../features/catalog/screens/product_detail_screen.dart';
import '../../features/ar_viewer/screens/ar_screen.dart';
import '../../features/calculator/screens/calculator_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/orders/screens/order_screen.dart';
import '../../features/orders/screens/order_success_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_shell.dart';

abstract class AppRoutes {
  static const login        = '/login';
  static const otp          = '/otp';
  static const catalog      = '/catalog';
  static const productDetail= '/catalog/:id';
  static const ar           = '/ar';
  static const calculator   = '/calculator';
  static const cart         = '/cart';
  static const order        = '/order';
  static const orderSuccess = '/order/success';
  static const subscription = '/subscription';
  static const profile      = '/profile';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.login, // TODO: Check auth state to redirect
  debugLogDiagnostics: true,
  routes: [
    // ── Auth flow ────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (ctx, state) => _fade(const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      pageBuilder: (ctx, state) {
        final map = state.extra as Map<String, dynamic>? ?? {};
        return _slide(OtpScreen(
          phone: map['phone'] as String? ?? '', 
          verificationId: map['vid'] as String? ?? ''
        ));
      },
    ),

    // ── Main shell (bottom nav) ──────────────────────────────
    ShellRoute(
      builder: (ctx, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.catalog,
          name: 'catalog',
          pageBuilder: (ctx, state) => _fade(const CatalogScreen()),
          routes: [
            GoRoute(
              path: ':id',
              name: 'product-detail',
              pageBuilder: (ctx, state) => _slide(
                ProductDetailScreen(productId: state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.ar,
          name: 'ar',
          pageBuilder: (ctx, state) => _fade(
            ArScreen(productId: state.extra as String?),
          ),
        ),
        GoRoute(
          path: AppRoutes.calculator,
          name: 'calculator',
          pageBuilder: (ctx, state) => _fade(const CalculatorScreen()),
        ),
        GoRoute(
          path: AppRoutes.cart,
          name: 'cart',
          pageBuilder: (ctx, state) => _fade(const CartScreen()),
          routes: [
            GoRoute(
              path: AppRoutes.order,
              name: 'order',
              pageBuilder: (ctx, state) => _slide(const OrderScreen()),
            ),
            GoRoute(
              path: AppRoutes.orderSuccess,
              name: 'order-success',
              pageBuilder: (ctx, state) => _fade(const OrderSuccessScreen()),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.subscription,
          name: 'subscription',
          pageBuilder: (ctx, state) => _fade(const SubscriptionScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          pageBuilder: (ctx, state) => _fade(const ProfileScreen()),
        ),
      ],
    ),
  ],
);

// ── Page transitions ─────────────────────────────────────────
CustomTransitionPage<void> _fade(Widget child) => CustomTransitionPage(
  child: child,
  transitionsBuilder: (ctx, anim, _, c) =>
      FadeTransition(opacity: anim, child: c),
  transitionDuration: const Duration(milliseconds: 200),
);

CustomTransitionPage<void> _slide(Widget child) => CustomTransitionPage(
  child: child,
  transitionsBuilder: (ctx, anim, _, c) => SlideTransition(
    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: c,
  ),
  transitionDuration: const Duration(milliseconds: 280),
);
