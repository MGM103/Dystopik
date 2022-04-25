const { EtherscanProvider } = require("@ethersproject/providers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Attributes", () => {
  let dystopikContract;
  let attributesContract;
  let owner, addr1;
  const id = 1;
  const strength = 5, speed = 5, fortitude = 5, technical = 2, instinct = 2, dexterity = 3, luck = 3;

  beforeEach(async () => {
    //Constructor arguement for dystopik
    const imageURIs = [
      "https://i.pinimg.com/564x/f7/cc/b5/f7ccb5a281a6c12773eb486b369d7f89.jpg",
      "https://i.pinimg.com/564x/55/b9/04/55b9046000c50ce93fb17da7c2abe6a7.jpg",
      "https://i.pinimg.com/564x/dd/6f/47/dd6f4703cd14c56af1fab2cbb6e5eb7c.jpg"
    ]

    const dystopikFactory = await ethers.getContractFactory("Dystopik");
    dystopikContract = await dystopikFactory.deploy(imageURIs);
    await dystopikContract.deployed();

    //mint a character
    const architype = 1;
    let mintTx = await dystopikContract.createCharacter(architype);
    await mintTx.wait();

    //constructor argument for attribute contract
    const dystopikAddr = dystopikContract.address;

    const attributeFactory = await ethers.getContractFactory("Attributes");
    attributesContract = await attributeFactory.deploy(dystopikAddr);
    await attributesContract.deployed();

    [owner, addr1] = await ethers.getSigners();
  })

  it("Will emit an event when initial attributes are set and set available pts to 0", async () => {
    const expectedPts = 0;

    await expect(
        attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, instinct, dexterity, luck)
    ).to.emit(attributesContract, "initialisedAttributes");

    let txn = await attributesContract.calcAvailablePts(id);
    expect(txn).to.equal(expectedPts);

    let initSetBool = await attributesContract.initAttributesSet(id);
    expect(initSetBool).to.equal(true);

    let currAttr = await attributesContract.idToAttributes(id);
    expect(currAttr.strength).to.equal(strength);
    expect(currAttr.speed).to.equal(speed);
    expect(currAttr.fortitude).to.equal(fortitude);
    expect(currAttr.technical).to.equal(technical);
    expect(currAttr.instinct).to.equal(instinct);
    expect(currAttr.dexterity).to.equal(dexterity);
    expect(currAttr.luck).to.equal(luck);
  });

  it("Will not let you set the attributes if you are not the owner or approved", async () => {
    await expect(
        attributesContract.connect(addr1).setInitAttributes(id, strength, speed, fortitude, technical, instinct, dexterity, luck)
    ).to.be.revertedWith("You do not have permission to set attributes");
  });

  it("Will not let you set the attributes if they have already been set", async () => {
    let setTx = await attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, instinct, dexterity, luck);
    await setTx.wait();

    await expect(
        attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, instinct, dexterity, luck)
    ).to.be.revertedWith("Initial attributes have already been set");
  });

  it("Will revert if all initial attribute points aren't spent", async () => {
    const invStr = 1;

    await expect(
      attributesContract.setInitAttributes(id, invStr, speed, fortitude, technical, instinct, dexterity, luck)
    ).to.be.revertedWith("All initial attribute points must be used");
  });

  it("Will revert attribute upgrade if character has insufficient attribute points", async () => {
    let txn = await attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, instinct, dexterity, luck);
    await txn.wait();

    await expect(
      attributesContract.increaseStr(id)
    ).to.be.revertedWith("Insufficent attribute points");
  });

  it("Will revert attribute upgrade if msg sender isn't owner or approved", async () => {
    let txn = await attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, instinct, dexterity, luck);
    await txn.wait();

    await expect(
      attributesContract.connect(addr1).increaseStr(id)
    ).to.be.revertedWith("You do not have permission to upgrade attributes");
  });

  it("Will revert attribute upgrade if attributes aren't set", async () => {
    await expect(
      attributesContract.increaseStr(id)
    ).to.be.revertedWith("Initial attributes have not been set");
  });

  context("Increasing attributes when they've been set and are lvl 2", async () => {
    beforeEach(async () => {
      const givenXp = 100;

      let txn = await dystopikContract.gainXp(id, givenXp);
      await txn.wait();

      let lvlUpTxn = await dystopikContract.levelUp(id);
      await lvlUpTxn.wait();

      let setTxn = await attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, instinct, dexterity, luck);
      await setTxn.wait();
    });

    it("Levels up strength", async () => {
      let txn = await attributesContract.increaseStr(id);
      await txn.wait();

      expect(txn).to.emit(attributesContract, "attributesUpgraded");

      const expectedSpend = 1;
      let pointsSpent = await attributesContract.idToAttributePointsSpent(id);
      expect(pointsSpent).to.equal(expectedSpend);

      let currAttr = await attributesContract.idToAttributes(id);
      expect(currAttr.strength).to.equal(strength + expectedSpend);
    });

    it("Levels up speed", async () => {
      let txn = await attributesContract.increaseSpd(id);
      await txn.wait();

      expect(txn).to.emit(attributesContract, "attributesUpgraded");

      const expectedSpend = 1;
      let pointsSpent = await attributesContract.idToAttributePointsSpent(id);
      expect(pointsSpent).to.equal(expectedSpend);

      let currAttr = await attributesContract.idToAttributes(id);
      expect(currAttr.speed).to.equal(speed + expectedSpend);
    });

    it("Levels up fortitude", async () => {
      let txn = await attributesContract.increaseFort(id);
      await txn.wait();

      expect(txn).to.emit(attributesContract, "attributesUpgraded");

      const expectedSpend = 1;
      let pointsSpent = await attributesContract.idToAttributePointsSpent(id);
      expect(pointsSpent).to.equal(expectedSpend);

      let currAttr = await attributesContract.idToAttributes(id);
      expect(currAttr.fortitude).to.equal(fortitude + expectedSpend);
    });

    it("Levels up technical", async () => {
      let txn = await attributesContract.increaseTech(id);
      await txn.wait();

      expect(txn).to.emit(attributesContract, "attributesUpgraded");

      const expectedSpend = 1;
      let pointsSpent = await attributesContract.idToAttributePointsSpent(id);
      expect(pointsSpent).to.equal(expectedSpend);

      let currAttr = await attributesContract.idToAttributes(id);
      expect(currAttr.technical).to.equal(technical + expectedSpend);
    });

    it("Levels up instinct", async () => {
      let txn = await attributesContract.increaseInstinct(id);
      await txn.wait();

      expect(txn).to.emit(attributesContract, "attributesUpgraded");

      const expectedSpend = 1;
      let pointsSpent = await attributesContract.idToAttributePointsSpent(id);
      expect(pointsSpent).to.equal(expectedSpend);

      let currAttr = await attributesContract.idToAttributes(id);
      expect(currAttr.instinct).to.equal(instinct + expectedSpend);
    });

    it("Levels up dexterity", async () => {
      let txn = await attributesContract.increaseDex(id);
      await txn.wait();

      expect(txn).to.emit(attributesContract, "attributesUpgraded");

      const expectedSpend = 1;
      let pointsSpent = await attributesContract.idToAttributePointsSpent(id);
      expect(pointsSpent).to.equal(expectedSpend);

      let currAttr = await attributesContract.idToAttributes(id);
      expect(currAttr.dexterity).to.equal(dexterity + expectedSpend);
    });

    it("Levels up luck", async () => {
      let txn = await attributesContract.increaseLuck(id);
      await txn.wait();

      expect(txn).to.emit(attributesContract, "attributesUpgraded");

      const expectedSpend = 1;
      let pointsSpent = await attributesContract.idToAttributePointsSpent(id);
      expect(pointsSpent).to.equal(expectedSpend);

      let currAttr = await attributesContract.idToAttributes(id);
      expect(currAttr.luck).to.equal(luck + expectedSpend);
    });

    it("Reverts if point spend is greater than available points", async () => {
      let availablePts = 5;

      for(let i = 0; i <= availablePts; i++){
        if(i == availablePts){
          await expect(
            attributesContract.increaseLuck(id)
          ).to.be.revertedWith("Insufficent attribute points");
        }else{
          let txn = await attributesContract.increaseFort(id);
          await txn.wait();
        }
      }

    });
  });
});
