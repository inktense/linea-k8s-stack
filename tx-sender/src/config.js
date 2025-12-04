import yargs from "yargs";
import { hideBin } from "yargs/helpers";
import dotenv from "dotenv";

dotenv.config();

const argv = yargs(hideBin(process.argv))
  .option("pk", {
    alias: "privateKey",
    type: "string",
    describe: "Sender private key"
  })
  .option("address", {
    type: "string",
    describe: "Recipient address"
  })
  .option("rpc", {
    type: "string",
    describe: "RPC endpoint"
  })
  .option("interval", {
    type: "number",
    default: 1,
    describe: "Interval in seconds"
  })
  .option("amount", {
    type: "number",
    default: 10,
    describe: "Amount in wei"
  })
  .help()
  .parse();

export const config = {
  privateKey:
    argv.pk ||
    process.env.PRIVATE_KEY ||
    (() => {
      throw new Error("PRIVATE_KEY not provided");
    })(),

  toAddress:
    argv.address ||
    process.env.TO_ADDRESS ||
    (() => {
      throw new Error("TO_ADDRESS not provided");
    })(),

  rpcUrl: process.env.RPC_URL || argv.rpc || "http://localhost:8545",
  interval: argv.interval || Number(process.env.INTERVAL_SECONDS || 1),
  amount: argv.amount || Number(process.env.AMOUNT_WEI || 10)
};
