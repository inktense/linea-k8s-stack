import { config } from "./config.js";
import { createSender } from "./sender.js";

console.log("Starting Linea tx-sender service...");
console.log("RPC URL:", config.rpcUrl);
createSender(config);
