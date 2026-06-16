class DynamicLoadingPage {
  constructor(page) {
    this.page = page;

    this.startButton = page.locator('#start button');
    this.spinner = page.locator('#loading');
    this.result = page.locator('#finish h4');
  }

  async open() {
    await this.page.goto('/dynamic_loading/1');
  }

  async startLoading() {
    await this.startButton.click();
  }
}

module.exports = { DynamicLoadingPage };