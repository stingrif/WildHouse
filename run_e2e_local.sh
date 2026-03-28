#!/bin/bash
set -e

echo "🐳 1. Запуск базы данных и кэша (Docker Compose)..."
cd "$(dirname "$0")"
docker compose up -d

echo "🔨 2. Установка зависимостей NestJS API..."
cd nestjs_api
cp .env.example .env
npm install
npm run build

echo "🚀 3. Запуск NestJS API (В фоне)..."
npm run start:prod &
NEST_PID=$!
cd ..

echo "📱 4. Сборка Flutter Web-приложения..."
cd flutter_app
flutter pub get
flutter build web --web-renderer canvaskit --profile

echo "🌐 5. Запуск Flutter Web-сервера (В фоне)..."
npx serve -l 3000 build/web &
FLUTTER_PID=$!
cd ..

echo "⏳ Ожидание запуска серверов (10 секунд)..."
sleep 10

echo "🎭 6. Запуск E2E Playwright тестов..."
cd e2e_tests
npx playwright test --project="Mobile Chrome"

echo "🧹 7. Очистка и остановка фоновых процессов..."
kill $NEST_PID
kill $FLUTTER_PID

echo "✅ Завершено!"
