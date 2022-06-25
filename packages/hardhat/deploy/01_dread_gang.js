// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  
  // Getting a previously deployed contract
  const dgToken = await ethers.getContract("DGToken", deployer);

  // deploy ("DreadGang")
  await deploy("DreadGang", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      "DreadGang NFT",
      "DADA",
      "",
      "",
      "0xDc06312e21053dE7ecf7B00E3910f12BcC240BbF",
      dgToken.address
    ],
    log: true,
  });


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

module.exports.tags = ["DreadGang"];
