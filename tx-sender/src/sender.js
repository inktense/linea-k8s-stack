import { ethers } from "ethers";

export async function createSender(config) {
  const provider = new ethers.JsonRpcProvider(config.rpcUrl);
  const wallet = new ethers.Wallet(config.privateKey, provider);

  console.log("Connected wallet:", wallet.address);
  console.log("Sending", config.amount, "wei every", config.interval, "seconds");

  let isSending = false;

  async function sendTx() {
    // Prevent overlapping transactions
    if (isSending) {
      console.log("Previous transaction still pending, skipping...");
      return;
    }

    try {
      isSending = true;
      
      // Fetch current nonce from network to ensure we're in sync
      const currentNonce = await provider.getTransactionCount(wallet.address, "pending");
      
      const tx = await wallet.sendTransaction({
        to: config.toAddress,
        value: config.amount,
        nonce: currentNonce
      });

      console.log("TX sent:", tx.hash, "nonce:", currentNonce);
      
      // Wait for confirmation
      const receipt = await tx.wait();
      console.log("TX confirmed in block:", receipt.blockNumber);
      
      isSending = false;
    } catch (err) {
      isSending = false;
      
      // Handle nonce errors specifically
      if (err.message && err.message.includes("nonce")) {
        console.error("Nonce error - will retry on next interval:", err.message);
      } else {
        console.error("TX error:", err.message);
      }
    }
  }

  return setInterval(sendTx, config.interval * 1000);
}
