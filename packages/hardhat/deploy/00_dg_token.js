// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  const ownerAddress = "0xCA7632327567796e51920F6b16373e92c7823854";

  await deploy("DGToken", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [ownerAddress],
    log: true,
  });

  const dgToken = await ethers.getContract("DGToken", deployer)

  // await deploy("DGToken", {
  await deploy("LevelingSVGNFT", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      "Leveling Collectible",
      "LVC",
      "0x7d7d3593f46ebdfd00438423f05eb762479a775c",
      dgToken.address,
    ],
    log: true,
  });

  const Collectible = await ethers.getContract("LevelingSVGNFT", deployer);
  // To take ownership of yourContract
  // address you want to be the owner.
  const tx = await Collectible.transferOwnership(ownerAddress);
  console.log("Transferring ownership to::", ownerAddress);
  console.log("Transfer Completed with txn hash:", tx.hash);
  // ToDo: Verify your contract with Etherscan for public chains
  // if (chainId !== "31337") {
  //   try {
  //     console.log(" 🎫 Verifing Contract on Etherscan... ");
  //     await sleep(3000); // wait 3 seconds for deployment to propagate bytecode
  //     await run("verify:verify", {
  //       address: yourCollectible.address,
  //       contract: "contracts/YourCollectible.sol:YourCollectible",
  //       // contractArguments: [yourToken.address],
  //     });
  //   } catch (e) {
  //     console.log(" ⚠️ Failed to verify contract on Etherscan ");
  //   }
  // }
};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports.tags = ["DGToken", "LevelingSVGNFT"];
// module.exports.tags = ["DGToken", "LevelingSVGNFT"];
