import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { isAddress, parseEther } from "ethers";
import { SaveERC20__factory } from "../typechain-types";

describe("SaveERC20", function () {
  async function deployFixture() {
    const [owner, otherAccount, addr1, addr2] = await ethers.getSigners();

    const Abel = await ethers.getContractFactory("Abel");
    const abelContract = await Abel.deploy();

    const SaveERC20 = await ethers.getContractFactory("SaveERC20");
    const saveERC20Contract = await SaveERC20.deploy(
      await abelContract.getAddress()
    );

    console.log(
      `ERC20 contract deployed to ${await abelContract.getAddress()}`
    );

    console.log(
      `saveEtherERC20 contract deployed to ${await saveERC20Contract.getAddress()}`
    );

    it("Should get approval From Token Contract to Deposit into Savings Contract", async function () {
      const { abelContract, saveERC20Contract } = await loadFixture(
        deployFixture
      );

      expect(
        await abelContract.approve(
          saveERC20Contract.getAddress(),
          parseEther("1")
        )
      );
      expect(
        await abelContract.allowance(
          abelContract.getAddress(),
          saveERC20Contract.getAddress()
        )
      );
    });

    return { saveERC20Contract, abelContract, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should deploy Token Abel First and Set Owner", async function () {
      const { abelContract, saveERC20Contract, owner } = await loadFixture(
        deployFixture
      );
      //console.log(owner);

      expect(await saveERC20Contract.ownerAddress()).to.equal(owner.address);
      expect(await abelContract.owner()).to.equal(owner.address);
    });

    it("Should Deposit 1 Ethers and 1 Abel(ERC20) to Saver Contract", async function () {
      const { abelContract, saveERC20Contract, owner } = await loadFixture(
        deployFixture
      );

      expect(await saveERC20Contract.deposit(parseEther("1")));
    });
  });
});
