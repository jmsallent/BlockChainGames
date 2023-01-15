const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const web3 = require("web3");
function getDate() {
  const currentDateObj = new Date();
  const numberOfMlSeconds = currentDateObj.getTime();
  const addMlSeconds = 60 * 60 * 1000;
  const newDateObj = new Date(numberOfMlSeconds + addMlSeconds);
  return newDateObj;
}
describe("Simple Lottery", () => {
  const TimeStamp = getDate().getTime();
  describe("Test Deploy", () => {
    it.skip("should deploy", async () => {
      const simpleLotteryFactory = await ethers.getContractFactory(
        "SimpleLottery"
      );
      const contract = await simpleLotteryFactory.deploy(TimeStamp);
      const result = await contract.ticketingCloses();
      expect(result).to.be.equal(TimeStamp);
    });
  });

  describe("Methods", () => {
    let contract;
    let owner, user1, user2;
    const ticketPrice = 0.01; // 0.01 ether
    const ticketPriceInWei = () => {
      return web3.utils.toWei(ticketPrice.toString(), "ether");
    };
    beforeEach(async () => {
      [owner, user1, user2] = await ethers.getSigners();
      const simpleLotteryFactory = await ethers.getContractFactory(
        "SimpleLottery"
      );
      contract = await simpleLotteryFactory.deploy(TimeStamp);
    });

    describe("Method buy", () => {
      it("should buy a ticket", async () => {
        const tx = await contract.connect(user1).buy({
          value: ticketPriceInWei(),
        });
        await tx.wait();
        console.log(user1.address);
        const result = await contract.tickets(0);
        expect(result).to.be.equal(user1.address);
      });
    });

    describe("drawWinner Method", () => {
      beforeEach(async () => {
        const tx = await contract.connect(user1).buy({
          value: ticketPriceInWei(),
        });
        await tx.wait();
        console.log(user1.address);
        const result = await contract.tickets(0);
      });

      it("Should win address 1", async () => {
        const txDraw = await contract.drawWinner();
        await txDraw.wait();

        const result = await contract.winner();
        expect(result).to.be.equal(user1.address);
      });
    });
    describe("withdraw", () => {
      beforeEach(async () => {
        const tx = await contract.connect(user1).buy({
          value: ticketPriceInWei(),
        });
        await tx.wait();
        console.log(user1.address);
        const result = await contract.tickets(0);
        const txDraw = await contract.drawWinner();
        await txDraw.wait();
      });

      it("user1 sould withdrawthe price", async () => {
        const tx = await contract.connect(user1).withdraw();
        await tx.wait();
      });
    });
  });
});
