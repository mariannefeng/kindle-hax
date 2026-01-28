import express from "express";
import { fetchBusArrivals } from "./graphql-client";
import { generateHTML } from "./html-generator";
import { generateImageFromHTML, closeBrowser } from "./image-generator";

const app = express();
const PORT = process.env.PORT || 3000;

function formatRefreshTime(date: Date): string {
  const dayOfWeek = date.toLocaleDateString("en-US", { weekday: "long" });
  const dateTime = date.toLocaleString("en-US");
  return `${dayOfWeek}, ${dateTime}`;
}

app.get("/screen", async (req, res) => {
  try {
    const busArrivals = await fetchBusArrivals();

    const refreshTime = formatRefreshTime(new Date());
    const html = generateHTML(busArrivals, refreshTime);

    const imageBuffer = await generateImageFromHTML(html, 600, 800);

    res.setHeader("Content-Type", "image/png");
    res.setHeader("Cache-Control", "no-cache");
    res.send(imageBuffer);
  } catch (error) {
    console.error("Error generating image:", error);
    res.status(500).json({
      error: "Failed to generate image",
      message: error instanceof Error ? error.message : "Unknown error",
    });
  }
});

app.get("/html", async (req, res) => {
  const busArrivals = await fetchBusArrivals();
  const refreshTime = formatRefreshTime(new Date());
  const html = generateHTML(busArrivals, refreshTime);
  res.send(html);
});

// call close browser explicitly so puppeteer can clean up
const shutdown = async (signal: string) => {
  console.log(`${signal} received, closing browser...`);
  await closeBrowser();
  process.exit(0);
};

// sent by docker to request shutdown
process.on("SIGTERM", () => shutdown("SIGTERM"));

// sent by ctrl + c in the terminal
process.on("SIGINT", () => shutdown("SIGINT"));

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`Image endpoint: http://localhost:${PORT}/screen`);
  console.log(`HTML endpoint: http://localhost:${PORT}/html`);
});
