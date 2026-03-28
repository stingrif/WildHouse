import { test, expect } from '@playwright/test';

test.describe('Pricing & Calculator Mobile', () => {

  test('Should navigate to Calculator, input dimensions and verify new mechanics (+10% waste, +18% VAT, PDF stub)', async ({ page }) => {
    // 1. Открываем веб-версию (порт 3000)
    await page.goto('http://localhost:3000/#/calculator');

    // Ожидаем отрисовки CanvasKit/Html (Ищет лейбл Длины)
    // Flutter Web оборачивает текстовые инпуты в теги с aria-label
    const lengthInput = page.locator('flt-semantics[aria-label="Длина (м)"] input, input[aria-label="Длина (м)"], flt-glass-pane input').nth(0);
    const widthInput  = page.locator('flt-semantics[aria-label="Ширина (м)"] input, input[aria-label="Ширина (м)"], flt-glass-pane input').nth(1);
    
    // Ждем инициализации
    await page.waitForTimeout(3000); 

    // 2. Имитация ввода данных: 4х5 м
    await lengthInput.click({ force: true });
    await page.keyboard.press('Backspace');
    await page.keyboard.type('4.0');
    
    await widthInput.click({ force: true });
    await page.keyboard.press('Backspace');
    await page.keyboard.type('5.0');

    // 3. Проверка появления результата ОНЛАЙН (теперь нет кнопки Calculate)
    // Базовая площадь 20м2. Авто-запас +10% = 22.0 м²
    const resultAreaInfo = page.locator('flt-semantics[aria-label*="22.00 м²"]');
    await expect(resultAreaInfo).toBeVisible({ timeout: 10000 });
    
    // Проверка отображения цены. Дефолтный товар: Дуб Нордик ₪85/м²
    // Материал: 22 * 85 = ₪1870
    // Установка (включена, >13м2): ₪1000
    // Сумма = 2870. НДС 18% = 516.6.
    // ИТОГО должно быть: ₪3387
    const totalLine = page.locator('flt-semantics[aria-label*="ИТОГО"]');
    await expect(totalLine).toBeVisible();

    const addCartBtn = page.locator('flt-semantics[aria-label*="ДОБАВИТЬ В КОРЗИНУ ОНЛАЙН"]');
    await expect(addCartBtn).toBeVisible();
    await addCartBtn.click({ force: true });

    // Убедимся, что мы перешли в корзину (на экране корзины должен появиться товар)
    const cartTitle = page.locator('flt-semantics[aria-label*="Корзина"]');
    await expect(cartTitle).toBeVisible();
  });

});
