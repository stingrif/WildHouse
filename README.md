# 🌿 Wild House — AR Flooring & Cladding

Мобильное приложение для подбора, AR-примерки и заказа паркета/облицовки.

---

## Структура проекта

```
wildhouse/
├── flutter_app/          # Мобильное приложение (Android-first, iOS v2)
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/   app_colors.dart
│   │   │   ├── theme/       app_theme.dart
│   │   │   └── router/      app_router.dart
│   │   ├── features/
│   │   │   ├── auth/        login_screen, otp_screen
│   │   │   ├── catalog/     catalog_screen, product_detail_screen
│   │   │   ├── ar_viewer/   ar_screen (ARCore bridge)
│   │   │   ├── calculator/  calculator_screen
│   │   │   ├── cart/        cart_screen
│   │   │   ├── orders/      order_screen, order_success_screen
│   │   │   ├── subscription/subscription_screen
│   │   │   └── profile/     profile_screen
│   │   └── shared/
│   │       ├── models/      Product, Order, Subscription, User
│   │       └── widgets/     MainShell (BottomNav)
│   └── pubspec.yaml
│
├── nestjs_api/           # Backend REST API
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/        Firebase OTP + JWT
│   │   │   ├── catalog/     Products, filters, pagination
│   │   │   ├── pricing/     Calculator: VAT, token-discount, installation
│   │   │   ├── orders/      Cart, order flow, payment
│   │   │   ├── subscriptions/ Plans: Basic/Standard/Pro
│   │   │   └── media/       GCS upload + CDN textures
│   │   ├── main.ts
│   │   └── app.module.ts
│   ├── .env.example
│   └── package.json
│
└── docker-compose.yml    # PostgreSQL 16 + Redis 7
```

---

## Стек

| Слой | Технология |
|------|------------|
| Mobile | Flutter 3.x + Dart |
| AR (Android) | ARCore via platform channel |
| AR (iOS v2) | ARKit bridge (без рефакторинга UI) |
| State | Riverpod + go_router |
| Backend | NestJS (TypeScript) |
| Database | PostgreSQL 16 (TypeORM) |
| Cache / Queue | Redis + BullMQ |
| Auth | Firebase Auth (OTP) + JWT |
| Payments | Stripe + Tranzila + TON Connect |
| Storage | Google Cloud Storage (CDN) |
| CI/CD | GitHub Actions + Cloud Build |

---

## Запуск (local dev)

### 1. Backend

```bash
cd nestjs_api
cp .env.example .env        # заполнить переменные
docker compose up -d        # PostgreSQL + Redis
npm install
npm run start:dev           # http://localhost:3001
                            # Swagger: http://localhost:3001/docs
```

### 2. Flutter App

```bash
cd flutter_app
flutter pub get
flutter run                 # подключить Android-устройство или эмулятор
```

> **Требования:** Android 8+ (API 26+) для ARCore, Flutter 3.22+

---

## Бизнес-логика

### Подписки
| План | Цена | Период | AR-сессии |
|------|------|--------|-----------|
| Basic | ₪50 | неделя | 5/неделю |
| Standard | ₪300 | месяц | Безлимит |
| Pro | ₪500 | месяц | Безлимит + B2B |

- Первая AR-сессия — **бесплатно** для каждого аккаунта
- Скидка **15%** на материалы при оплате токеном Wild House

### НДС
Все расчёты показывают НДС 18% отдельной строкой.

### Запас материала
Калькулятор автоматически добавляет **+10%** к площади.

---

## Палитра бренда

| Название | HEX |
|----------|-----|
| Oak | `#D6B48A` |
| Walnut | `#8B5E3C` |
| Sand | `#F4EBDD` |
| Graphite | `#3C3C3C` |
| Moss | `#6C7A5A` |

Шрифты: **Cormorant** (заголовки) + **Jost** (интерфейс)

---

## Следующие шаги

- [ ] Подключить реальный ARCore плагин (`arcore_flutter_plugin`)
- [ ] Riverpod провайдеры для каталога и корзины
- [ ] API service layer (Dio + Retrofit)
- [ ] Firebase Auth полная интеграция
- [ ] Stripe / Tranzila payment flow
- [ ] TON Connect для токен-скидки
- [ ] Admin Panel (Next.js)
- [ ] iOS ARKit bridge (v2)
- [ ] Локализация: иврит (RTL), английский
