const { EtherscanProvider } = require("@ethersproject/providers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Attributes", () => {
  let dystopikContract;
  let attributesContract;
  let owner, addr1;

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
    let mintTx = await dystopikContract.createCharacter(1);
    await mintTx.wait();

    //constructor argument for attribute contract
    const dystopikAddr = dystopikContract.address;

    const attributeFactory = await ethers.getContractFactory("Attributes");
    attributesContract = await attributeFactory.deploy(dystopikAddr);
    await attributesContract.deployed();

    [owner, addr1] = await ethers.getSigners();
  })

  it("Will emit an event when initial attributes are set", async () => {
    const id = 1;
    let strength = 5, speed = 5, fortitude = 5, technical = 2, reflexes = 5, luck = 3;

    await expect(
        attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, reflexes, luck)
    ).to.emit(attributesContract, "initialisedAttributes");
  });

  it("Will return 0 points available for a newly created character", async () => {
    const id = 1;
    let strength = 5, speed = 5, fortitude = 5, technical = 2, reflexes = 5, luck = 3;
    const expectedPts = 0;

    let setTx = await attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, reflexes, luck);
    await setTx.wait();

    setTx = await attributesContract.calcAvailablePts(id);

    expect(setTx).to.equal(expectedPts);
  });

  it("Will not let you set the attributes if you are not the owner or approved", async () => {
    const id = 1;
    let strength = 5, speed = 5, fortitude = 5, technical = 2, reflexes = 5, luck = 3;

    await expect(
        attributesContract.connect(addr1).setInitAttributes(id, strength, speed, fortitude, technical, reflexes, luck)
    ).to.be.revertedWith("You do not have permission to set attributes");
  });

  it("Will not let you set the attributes if they have already been set", async () => {
    const id = 1;
    let strength = 5, speed = 5, fortitude = 5, technical = 2, reflexes = 5, luck = 3;

    let setTx = await attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, reflexes, luck);
    await setTx.wait();

    await expect(
        attributesContract.setInitAttributes(id, strength, speed, fortitude, technical, reflexes, luck)
    ).to.be.revertedWith("Initial attributes have already been set");
  });
});
