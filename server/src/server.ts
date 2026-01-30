import fs from "fs";
import path from "path";
import express from "express";
import { fetchBusArrivals } from "./graphql-client";
import { generateHTML } from "./html-generator";

const app = express();
const PORT = process.env.PORT || 3000;

const SCREEN_PNG_PATH =
  process.env.SCREEN_PNG_PATH || path.join(__dirname, "..", "screen.png");

const TIMEZONE = "America/New_York";

function formatRefreshTime(date: Date): string {
  const dayOfWeek = date.toLocaleDateString("en-US", {
    weekday: "long",
    timeZone: TIMEZONE,
  });
  const dateTime = date.toLocaleString("en-US", { timeZone: TIMEZONE });
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

app.get("/", async (req, res) => {
  const busArrivals = await fetchBusArrivals();
  const refreshTime = formatRefreshTime(new Date());
  const html = generateHTML(busArrivals, refreshTime, false);
  res.send(html);
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`Human endpoint: http://localhost:${PORT}`);
  console.log(`Kindle screen endpoint: http://localhost:${PORT}/screen`);
  console.log(
    `Kindle HTML (used to generate the screen) endpoint: http://localhost:${PORT}/html`,
  );
});
