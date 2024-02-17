import { ethers } from "hardhat";
import { Abel__factory } from "../typechain-types";

async function main() {
  const abel = await ethers.deployContract("Abel");

  await abel.waitForDeployment();

  console.log(`Contract deployed to ${abel.target}`);

  const saveEtherERC = await ethers.deployContract(
    "SaveERC20",
    await [abel.target]
  );

  await saveEtherERC.waitForDeployment();

  console.log(`Contract deployed to ${saveEtherERC.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
