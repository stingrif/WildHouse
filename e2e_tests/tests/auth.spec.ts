import { test, expect } from '@playwright/test';

test.describe('Authentication Flow Mobile', () => {

  test('Should navigate to Login, enter phone and verify OTP via mock', async ({ page }) => {
    // 1. Открытие главной (или экрана логина) Web-сборки Flutter 
    // Flutter Web добавляет семантические теги: <flt-semantics aria-label="...">
    // Для этого нужно включить a11y в Flutter Web (Semantics()...)
    await page.goto('/#/login'); // Роут из app_router.dart: AppRoutes.login = '/login'

    // 2. Ожидание отрисовки экрана (Flutter Canvas Loading timeout)
    // Ждём появления поля "Phone Number" или кнопки по семантическому лейблу
    const phoneInput = page.locator('flt-semantics[aria-label*="phone"], flt-glass-pane input').first();
    await phoneInput.waitFor({ state: 'visible', timeout: 15000 });

    // 3. Ввод номера телефона и отправка 
    // Для Flutter Web иногда требуется кликнуть и вводить через keyboard.type
    await phoneInput.click();
    await page.keyboard.type('+972555123456');
    
    // Клик по кнопке "Continue" (или стрелке Вперед)
    const loginButton = page.locator('flt-semantics[aria-label="Continue"]');
    await loginButton.click();

    // 4. Проверка перехода на экран OTP
    // Ожидаем изменение URL (редирект на /otp)
    await page.waitForURL('**/otp', { timeout: 10000 });
    
    // Вводим "123456" как mock-OTP
    const otpInput = page.locator('flt-semantics[aria-label*="OTP"], flt-glass-pane input').first();
    await otpInput.click();
    await page.keyboard.type('123456');

    // Клик по верификации
    const verifyButton = page.locator('flt-semantics[aria-label="Verify"]');
    await verifyButton.click();

    // 5. Проверка успешного редиректа в главный каталог AppRoutes.catalog = '/catalog'
    await page.waitForURL('**/catalog', { timeout: 10000 });
    
    // Утверждаем, что появился первый таббар (Catalog) 
    const catalogHeader = page.locator('flt-semantics[aria-label*="Wild House"]');
    await expect(catalogHeader).toBeVisible();
  });

});
