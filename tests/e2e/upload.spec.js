const path = require('node:path');
const { test, expect } = require('@playwright/test');
const { UploadPage } = require('../pages/UploadPage');

test('uploads a valid text file', async ({ page }) => {
  const uploadPage = new UploadPage(page);

  const filePath = path.join(
    __dirname,
    '../fixtures/sample-upload.txt'
  );

  await uploadPage.open();

  await uploadPage.upload(filePath);

  await expect(uploadPage.heading).toHaveText(
    'File Uploaded!'
  );

  await expect(uploadPage.uploadedFiles).toHaveText(
    'sample-upload.txt'
  );
});