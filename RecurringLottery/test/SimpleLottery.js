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
describe("RecurringLottery", () => {
  const TimeStamp = getDate().getTime();
  describe("Test Deploy", () => {
    it("should deploy", async () => {
      const simpleLotteryFactory = await ethers.getContractFactory(
        "RecurringLottery"
      );
      const contract = await simpleLotteryFactory.deploy(TimeStamp);
    });
  });
});
