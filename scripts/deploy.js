const hre = require("hardhat");

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;


  const mySwap = await hre.ethers.getContractFactory("MySwap");
  const MySwap = await mySwap.deploy();

  await MySwap.deployed();

  console.log(`MySwap deployed to ${MySwap.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
