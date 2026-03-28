// lib/shared/models/product.dart
class Product {
  final String id;
  final String sku;
  final String name;
  final String brand;
  final String collection;
  final String categoryId;
  final String colorName;
  final String? colorHex;
  final double thicknessMm;
  final String wearClass;       // AC1..AC6
  final bool moistureResistant;
  final String installType;     // glue / lock / glue_lock / floating
  final bool floorHeatCompat;
  final double pricePerM2;
  final double vatRate;
  final List<String> photoUrls;
  final String textureUrl;
  final double stockQty;
  final double reservedQty;
  final bool isActive;
  final bool isFeatured;
  final Map<String, dynamic>? attributes;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.brand,
    required this.collection,
    required this.categoryId,
    required this.colorName,
    this.colorHex,
    required this.thicknessMm,
    required this.wearClass,
    required this.moistureResistant,
    required this.installType,
    required this.floorHeatCompat,
    required this.pricePerM2,
    required this.vatRate,
    required this.photoUrls,
    required this.textureUrl,
    required this.stockQty,
    required this.reservedQty,
    required this.isActive,
    required this.isFeatured,
    this.attributes,
  });

  double get priceWithVat => pricePerM2 * (1 + vatRate / 100);
  double get availableQty  => stockQty - reservedQty;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id:               json['id'],
    sku:              json['sku'],
    name:             json['name'],
    brand:            json['brand'],
    collection:       json['collection'],
    categoryId:       json['category_id'],
    colorName:        json['color_name'],
    colorHex:         json['color_hex'],
    thicknessMm:      (json['thickness_mm'] as num).toDouble(),
    wearClass:        json['wear_class'],
    moistureResistant:json['moisture_resistant'] ?? false,
    installType:      json['install_type'],
    floorHeatCompat:  json['floor_heat_compat'] ?? false,
    pricePerM2:       (json['price_per_m2'] as num).toDouble(),
    vatRate:          (json['vat_rate'] as num?)?.toDouble() ?? 18.0,
    photoUrls:        List<String>.from(json['photo_urls'] ?? []),
    textureUrl:       json['texture_url'] ?? '',
    stockQty:         (json['stock_qty'] as num).toDouble(),
    reservedQty:      (json['reserved_qty'] as num?)?.toDouble() ?? 0,
    isActive:         json['is_active'] ?? true,
    isFeatured:       json['is_featured'] ?? false,
    attributes:       json['attributes'] as Map<String, dynamic>?,
  );
}

// ─────────────────────────────────────────────────────────────
// lib/shared/models/order.dart
class OrderLine {
  final String productId;
  final String productName;
  final double areaM2;
  final double pricePerM2;
  final bool includeInstallation;
  final double? installationPrice;

  const OrderLine({
    required this.productId,
    required this.productName,
    required this.areaM2,
    required this.pricePerM2,
    required this.includeInstallation,
    this.installationPrice,
  });

  double get subtotal => areaM2 * pricePerM2 +
      (includeInstallation ? (installationPrice ?? 0) : 0);
}

class Order {
  final String? id;
  final String userId;
  final List<OrderLine> lines;
  final String? installDate;
  final String address;
  final double totalInclVat;
  final String paymentMethod; // card / crypto
  final String? promoCode;
  final String status;        // draft / confirmed / in_progress / done

  const Order({
    this.id,
    required this.userId,
    required this.lines,
    this.installDate,
    required this.address,
    required this.totalInclVat,
    required this.paymentMethod,
    this.promoCode,
    this.status = 'draft',
  });
}

// ─────────────────────────────────────────────────────────────
// lib/shared/models/subscription.dart
enum SubscriptionPlan { basic, standard, pro }

extension SubscriptionPlanExt on SubscriptionPlan {
  String get label {
    switch (this) {
      case SubscriptionPlan.basic:    return 'Basic';
      case SubscriptionPlan.standard: return 'Standard';
      case SubscriptionPlan.pro:      return 'Pro';
    }
  }

  double get price {
    switch (this) {
      case SubscriptionPlan.basic:    return 50;
      case SubscriptionPlan.standard: return 300;
      case SubscriptionPlan.pro:      return 500;
    }
  }

  String get period {
    switch (this) {
      case SubscriptionPlan.basic:    return 'неделя';
      case SubscriptionPlan.standard: return 'месяц';
      case SubscriptionPlan.pro:      return 'месяц';
    }
  }
}

class Subscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final double price;
  final DateTime startAt;
  final DateTime endAt;
  final String status; // active / expired / cancelled

  const Subscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.price,
    required this.startAt,
    required this.endAt,
    required this.status,
  });

  bool get isActive => status == 'active' && endAt.isAfter(DateTime.now());
}

// ─────────────────────────────────────────────────────────────
// lib/shared/models/user_model.dart
class UserModel {
  final String id;
  final String? phone;
  final String? email;
  final String lang;            // ru / he / en
  final SubscriptionPlan? subscriptionPlan;
  final bool firstArSessionUsed;

  const UserModel({
    required this.id,
    this.phone,
    this.email,
    required this.lang,
    this.subscriptionPlan,
    required this.firstArSessionUsed,
  });

  bool get canUseAr =>
      !firstArSessionUsed || subscriptionPlan != null;
}
