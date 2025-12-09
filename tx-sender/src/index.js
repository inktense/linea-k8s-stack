import { config } from "./config.js";
import { createSender } from "./sender.js";
import { createServer } from "http";

console.log("Starting Linea tx-sender service...");
console.log("RPC URL:", config.rpcUrl);

// Start health check server
const healthPort = process.env.HEALTH_PORT || 8080;
const server = createServer((req, res) => {
  if (req.url === "/health" || req.url === "/healthz") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "healthy", service: "tx-sender" }));
  } else {
    res.writeHead(404, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Not found" }));
  }
});

server.listen(healthPort, () => {
  console.log(`Health check server listening on port ${healthPort}`);
});

// Start transaction sender
createSender(config);
