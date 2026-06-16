const { test, expect } = require('@playwright/test');
const { DynamicLoadingPage,} = require('../pages/DynamicLoadingPage');

test('reveals hidden content after dynamic loading', async ({ page }) => {
  const dynamicPage = new DynamicLoadingPage(page);

  await dynamicPage.open();

  await expect(dynamicPage.result).toBeHidden();
  await expect(dynamicPage.spinner).toBeHidden();

  await dynamicPage.startLoading();

  await expect(dynamicPage.spinner).toBeVisible();

  await expect(dynamicPage.spinner).toBeHidden({
    timeout: 10000,
  });

  await expect(dynamicPage.result).toBeVisible({
    timeout: 10000,
  });

  await expect(dynamicPage.result).toHaveText(
    'Hello World!'
  );
});