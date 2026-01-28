import fs from "fs";
import path from "path";
import express from "express";
import { fetchBusArrivals } from "./graphql-client";
import { generateHTML } from "./html-generator";

const app = express();
const PORT = process.env.PORT || 3000;

const SCREEN_PNG_PATH =
  process.env.SCREEN_PNG_PATH || path.join(__dirname, "..", "screen.png");

function formatRefreshTime(date: Date): string {
  const dayOfWeek = date.toLocaleDateString("en-US", { weekday: "long" });
  const dateTime = date.toLocaleString("en-US");
  return `${dayOfWeek}, ${dateTime}`;
}

app.get("/screen", (_req, res) => {
  if (!fs.existsSync(SCREEN_PNG_PATH)) {
    res.status(503).json({
      error: "Screen image not ready yet",
      message: "Wait for the next cron run or check logs.",
    });
    return;
  }
  res.setHeader("Content-Type", "image/png");
  res.setHeader("Cache-Control", "no-cache");
  res.sendFile(SCREEN_PNG_PATH);
});

app.get("/html", async (req, res) => {
  const busArrivals = await fetchBusArrivals();
  const refreshTime = formatRefreshTime(new Date());
  const html = generateHTML(busArrivals, refreshTime);
  res.send(html);
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`Image endpoint: http://localhost:${PORT}/screen`);
  console.log(`HTML endpoint: http://localhost:${PORT}/html`);
});
