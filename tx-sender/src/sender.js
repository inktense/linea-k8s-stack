import { ethers } from "ethers";

export async function createSender(config) {
  const provider = new ethers.JsonRpcProvider(config.rpcUrl);
  const wallet = new ethers.Wallet(config.privateKey, provider);

  console.log("Connected wallet:", wallet.address);
  console.log("Sending", config.amount, "wei every", config.interval, "seconds");

  async function sendTx() {
    try {
      const tx = await wallet.sendTransaction({
        to: config.toAddress,
        value: config.amount
      });

      console.log("TX sent:", tx.hash);
      await tx.wait();
      console.log("TX confirmed");
    } catch (err) {
      console.error("TX error:", err.message);
    }
  }

  return setInterval(sendTx, config.interval * 1000);
}
