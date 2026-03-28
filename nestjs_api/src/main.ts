// src/main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global prefix
  app.setGlobalPrefix('api/v1');

  // CORS
  app.enableCors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') ?? ['http://localhost:3000'],
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  // Validation
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    transformOptions: { enableImplicitConversion: true },
  }));

  // Swagger UI (dev only)
  if (process.env.NODE_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('Wild House API')
      .setDescription('AR Flooring & Cladding — REST API')
      .setVersion('1.0')
      .addBearerAuth()
      .addTag('auth', 'Authentication & OTP')
      .addTag('catalog', 'Products & Categories')
      .addTag('pricing', 'Calculator & Discounts')
      .addTag('orders', 'Cart & Orders')
      .addTag('subscriptions', 'Plans & Payments')
      .addTag('media', 'Image Upload & CDN')
      .build();
    const doc = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('docs', app, doc);
    console.log('📚 Swagger: http://localhost:3001/docs');
  }

  const port = process.env.PORT ?? 3001;
  await app.listen(port);
  console.log(`🌿 Wild House API running on port ${port}`);
}
bootstrap();
