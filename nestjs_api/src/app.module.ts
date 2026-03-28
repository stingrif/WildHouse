// src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { BullModule } from '@nestjs/bull';

import { AuthModule }         from './modules/auth/auth.module';
import { CatalogModule }      from './modules/catalog/catalog.module';
import { PricingModule }      from './modules/pricing/pricing.module';
import { OrdersModule }       from './modules/orders/orders.module';
import { SubscriptionsModule }from './modules/subscriptions/subscriptions.module';
import { MediaModule }        from './modules/media/media.module';

@Module({
  imports: [
    // ── Config ────────────────────────────────────────────────
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '.env' }),

    // ── Database ──────────────────────────────────────────────
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        type: 'postgres',
        url: cfg.get<string>('DATABASE_URL'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        migrations: [__dirname + '/migrations/*{.ts,.js}'],
        synchronize: cfg.get('NODE_ENV') !== 'production', // только dev!
        logging: cfg.get('NODE_ENV') === 'development',
        ssl: cfg.get('NODE_ENV') === 'production'
          ? { rejectUnauthorized: false }
          : false,
      }),
    }),

    // ── Rate limiting ─────────────────────────────────────────
    ThrottlerModule.forRoot([{
      ttl:   60000,  // 1 минута
      limit: 60,     // 60 запросов
    }]),

    // ── Queue (Redis) ─────────────────────────────────────────
    BullModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        redis: {
          host: cfg.get('REDIS_HOST', 'localhost'),
          port: cfg.get<number>('REDIS_PORT', 6379),
          password: cfg.get('REDIS_PASSWORD'),
        },
      }),
    }),

    // ── Feature modules ───────────────────────────────────────
    AuthModule,
    CatalogModule,
    PricingModule,
    OrdersModule,
    SubscriptionsModule,
    MediaModule,
  ],
})
export class AppModule {}
