import { config } from "./config.js";
import { createSender } from "./sender.js";

console.log("🚀 Starting Linea tx-sender service...");
createSender(config);
