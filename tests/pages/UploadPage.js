class UploadPage {
  constructor(page) {
    this.page = page;

    this.fileInput = page.locator('#file-upload');
    this.uploadButton = page.locator('#file-submit');
    this.heading = page.locator('h3');
    this.uploadedFiles = page.locator('#uploaded-files');
  }

  async open() {
    await this.page.goto('/upload');
  }

  async upload(filePath) {
    await this.fileInput.setInputFiles(filePath);
    await this.uploadButton.click();
  }
}

module.exports = { UploadPage };