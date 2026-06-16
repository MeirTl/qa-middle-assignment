const { test, expect } = require('@playwright/test');
const users = require('../fixtures/users.json');
const { LoginPage } = require('../pages/LoginPage');

test.describe('Form Authentication', () => {
  test('logs in and logs out with valid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page);

    await loginPage.open();

    await loginPage.login(
      users.valid.username,
      users.valid.password
    );

    await expect(page).toHaveURL(/\/secure$/);

    await expect(loginPage.flashMessage).toContainText(
      'You logged into a secure area!'
    );

    await expect(loginPage.logoutButton).toBeVisible();

    await loginPage.logout();

    await expect(page).toHaveURL(/\/login$/);

    await expect(loginPage.flashMessage).toContainText(
      'You logged out of the secure area!'
    );
  });

  for (const testData of users.invalid) {
    test(`rejects ${testData.name}`, async ({ page }) => {
      const loginPage = new LoginPage(page);

      await loginPage.open();

      await loginPage.login(
        testData.username,
        testData.password
      );

      await expect(page).toHaveURL(/\/login$/);

      await expect(loginPage.flashMessage).toContainText(
        testData.expectedMessage
      );
    });
  }
});