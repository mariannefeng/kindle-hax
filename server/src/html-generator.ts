import { BusArrival } from "./types";

export function generateHTML(
  busArrivals: BusArrival[],
  refreshTime: string,
): string {
  const next5 = busArrivals.slice(0, 5);

  const busItems = next5
    .map((arrival: BusArrival) => {
      const capacityDisplay = arrival.capacity || "N/A";

      return `
      <div class="bus-item">
        <div class="bus-header">
          <span class="route">${arrival.route}</span>
          <span class="departing-in">${arrival.departingIn}</span>
        </div>
        <div class="bus-destination">${arrival.destination}</div>
        <div class="bus-details">
          <span class="bus-time">${arrival.time}</span>
          <span class="capacity">${capacityDisplay}</span>
        </div>
      </div>
    `;
    })
    .join("");

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    html, body {
      width: 600px;
      height: 800px;
      margin: 0;
      padding: 0;
    }
    
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      overflow: hidden;
      transform: rotate(90deg);
    }
    
    .container {
      display: flex;
      flex-direction: column;
      height: 100%;
    }
    
    .refresh-time {
      font-size: 16px;
      margin-bottom: 10px;
      text-align: right;
    }
    
    .bus-list {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow-y: auto;
    }
    
    .bus-item {
      border-radius: 8px;
      padding: 10px;
      margin-bottom: 15px;
      border: 2px solid #000000;
    }
    
    .bus-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
    }
    
    .route {
      font-size: 28px;
      font-weight: 700;
    }
    
    .departing-in {
      font-size: 18px;
      font-weight: 600;
      background: #000000;
      color: #ffffff;
      padding: 6px 12px;
      border-radius: 4px;
    }
    
    .bus-destination {
      font-size: 16px;
      margin-bottom: 10px;
    }
    
    .bus-details {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 14px;
    }
    
    .capacity {
      padding: 4px 10px;
      border: 1px solid #000000;
      border-radius: 4px;
      font-weight: 600;
      font-size: 12px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="refresh-time">Last refreshed at: ${refreshTime}</div>
    <div class="bus-list">
      ${busItems}
    </div>
  </div>
</body>
</html>
  `.trim();
}
