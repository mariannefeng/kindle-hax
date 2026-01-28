import puppeteer, { Browser } from "puppeteer";

let browser: Browser | null = null;

async function getBrowser(): Promise<Browser> {
  if (!browser) {
    browser = await puppeteer.launch({
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    });
  }
  return browser;
}

export async function generateImageFromHTML(
  htmlContent: string,
  width = 600,
  height = 800,
): Promise<Buffer> {
  const browserInstance = await getBrowser();
  const page = await browserInstance.newPage();

  try {
    await page.setViewport({
      width: width,
      height: height,
      deviceScaleFactor: 1,
    });

    await page.setContent(htmlContent, {
      waitUntil: "networkidle0",
    });

    const buffer = (await page.screenshot({
      type: "png",
      fullPage: false,
    })) as Buffer;

    return buffer;
  } finally {
    await page.close();
  }
}

export async function closeBrowser(): Promise<void> {
  if (browser) {
    await browser.close();
    browser = null;
  }
}
