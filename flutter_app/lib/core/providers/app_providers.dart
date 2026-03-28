import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Currency State Logic ---
enum AppCurrency { ils, usd }

class CurrencyNotifier extends StateNotifier<AppCurrency> {
  CurrencyNotifier() : super(AppCurrency.ils);

  void toggle() {
    state = state == AppCurrency.ils ? AppCurrency.usd : AppCurrency.ils;
  }

  // Обменный курс-заглушка 1 USD = 3.7 ILS
  double convert(double valueInIls) {
    if (state == AppCurrency.usd) {
      return valueInIls / 3.7;
    }
    return valueInIls;
  }

  String format(double valueInIls) {
    final converted = convert(valueInIls);
    final symbol = state == AppCurrency.ils ? '₪' : '\$';
    return '$symbol${converted.toStringAsFixed(converted == converted.truncateToDouble() ? 0 : 2)}';
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, AppCurrency>((ref) {
  return CurrencyNotifier();
});

// --- Cart Logic (Riverpod cart provider) ---
class CartItemModel {
  final String id;
  final String name;
  final String brand;
  final double area;
  final double pricePerM2;
  final bool installIncluded;
  final double installPrice;

  CartItemModel({
    required this.id, required this.name, required this.brand,
    required this.area, required this.pricePerM2,
    required this.installIncluded, required this.installPrice,
  });
}

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addToCart(CartItemModel item) {
    state = [...state, item];
  }

  void removeFromCart(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  double get materialSubtotal => state.fold(0, (sum, item) => sum + (item.area * item.pricePerM2));
  double get installSubtotal => state.fold(0, (sum, item) => sum + (item.installIncluded ? item.installPrice : 0));
  
  double get subtotal => materialSubtotal + installSubtotal;
  double get vat => subtotal * 0.18;
  double get total => subtotal + vat;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});

// --- Auth State Logic ---
final authProvider = StateProvider<bool>((ref) => false);

// --- Locale Logic (i18n) ---
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ru'));

  void setLocale(Locale newLocale) {
    if (['ru', 'en', 'he'].contains(newLocale.languageCode)) {
      state = newLocale;
    }
  }
}
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());
