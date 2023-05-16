const hre = require("hardhat");

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;


  // do swap tx  here

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
