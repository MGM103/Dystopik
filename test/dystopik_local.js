const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dystopik", () => {
  let dystopikContract;
  let owner, addr1;

  beforeEach(async () => {
    const imageURIs = [
      "https://i.pinimg.com/564x/f7/cc/b5/f7ccb5a281a6c12773eb486b369d7f89.jpg",
      "https://i.pinimg.com/564x/55/b9/04/55b9046000c50ce93fb17da7c2abe6a7.jpg",
      "https://i.pinimg.com/564x/dd/6f/47/dd6f4703cd14c56af1fab2cbb6e5eb7c.jpg"
    ]
    const dystopikFactory = await ethers.getContractFactory("Dystopik");
    dystopikContract = await dystopikFactory.deploy(imageURIs);
    await dystopikContract.deployed();

    [owner, addr1] = await ethers.getSigners();
  })

  it("Creates a user's character correctly", async () => {
    const characterTypes = [1 ,2, 3];
    let mintTxn;
    let xp = 0, level = 1;
    const imageURIs = [
      "https://i.pinimg.com/564x/f7/cc/b5/f7ccb5a281a6c12773eb486b369d7f89.jpg",
      "https://i.pinimg.com/564x/55/b9/04/55b9046000c50ce93fb17da7c2abe6a7.jpg",
      "https://i.pinimg.com/564x/dd/6f/47/dd6f4703cd14c56af1fab2cbb6e5eb7c.jpg"
    ] 
    
    for(i = 0; i < characterTypes.length; i++){
      mintTxn = await dystopikContract.createCharacter(characterTypes[i]);
      await mintTxn.wait();

      expect(mintTxn).to.emit(dystopikContract, "characterCreated");

      mintTxn = await dystopikContract.getCharacter(i+1);

      expect(mintTxn[0].toNumber()).to.equal(xp);
      expect(mintTxn[1]).to.equal(level);
      expect(mintTxn[2]).to.equal(characterTypes[i]);
      expect(mintTxn[3]).to.equal(imageURIs[i]);
    }
  });

  it("Reverts when given an out of bounds character type", async () => {
    
  })
});
