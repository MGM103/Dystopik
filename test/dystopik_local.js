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
    const characterTypes = [0, 4];

    for(i = 0; i < characterTypes.length; i++){
      await expect(
        dystopikContract.createCharacter(characterTypes[i])
      ).to.be.revertedWith(
        "Architype does not exist"
      );
    }
  });

  it("Returns the correct string for the given architype", async () => {
    const architypes = [1, 2, 3];
    const expectedStrings = ["Chimera", "Android", "AI"];
    let archTx;
    
    for(i = 0; i < architypes.length; i++){
      archTx = await dystopikContract.architypeToString(architypes[i]);
      expect(archTx).to.equal(expectedStrings[i]);
    }
  });

  it("Reverts when a non-owner who doesn't have approval attempts to level up a character", async () => {
    const characterType = 1;
    const tokenID = 1;

    let txn = await dystopikContract.createCharacter(characterType);
    await txn.wait();

    await expect(
      dystopikContract.connect(addr1).levelUp(tokenID)
    ).to.be.revertedWith("You do not have approval to perform this action");
  });

  it("Reverts when a character has insufficient xp to level up", async () => {
    const characterType = 1;
    const tokenID = 1;

    let txn = await dystopikContract.createCharacter(characterType);
    await txn.wait();

    await expect(
      dystopikContract.levelUp(tokenID)
    ).to.be.revertedWith("Insufficent xp");
  });

  it("Assigns roles correctly", async () => {
    const DEFAULT_ADMIN_ROLE = '0x0000000000000000000000000000000000000000000000000000000000000000';
    const role_bytes = ethers.utils.toUtf8Bytes("XP_GIVER")
    const XP_GIVER = ethers.utils.keccak256(role_bytes);

    let txn = await dystopikContract.hasRole(DEFAULT_ADMIN_ROLE, owner.address);
    expect(txn).to.equal(true);

    txn = await dystopikContract.hasRole(XP_GIVER, owner.address);
    expect(txn).to.equal(true);

    txn = await dystopikContract.hasRole(DEFAULT_ADMIN_ROLE, addr1.address);
    expect(txn).to.equal(false);

    txn = await dystopikContract.hasRole(XP_GIVER, addr1.address);
    expect(txn).to.equal(false);
  });

  describe("Dystopik Xp", async () => {
    const charType = 1;
    const charID = 1;

    beforeEach(async () => {
      mintTxn = await dystopikContract.createCharacter(charType);
      await mintTxn.wait();
    })

    it("Calculates the xp value for the next level correctly", async () => {
      const levels = [1, 5, 10, 25, 50, 100];
      const expectedVals = [100, 2500, 10000, 62500, 250000, 1000000];
      let lvlRes;
      
      for(let i = 0; i < levels.length; i++) {
        lvlRes = await dystopikContract.nextLevelXp(levels[i]);
        expect(lvlRes).to.equal(expectedVals[i]);
      }
    });

    it("Prevents gaining xp without questing", async () => {
      const xpGiven = 100;
      const role_bytes = ethers.utils.toUtf8Bytes("XP_GIVER");
      const XP_GIVER = ethers.utils.keccak256(role_bytes);
      const errMsg = `AccessControl: account ${(addr1.address).toLowerCase()} is missing role ${XP_GIVER}`;
  
      await expect(
        dystopikContract.connect(addr1).gainXp(charID, xpGiven)
      ).to.be.revertedWith(errMsg);
    });
  
    it("Updates Xp correctly", async () => {
      const xpGiven = 100;
  
      let xpTxn = await dystopikContract.gainXp(charID, xpGiven);
      await xpTxn.wait();
  
      expect(xpTxn).to.emit(dystopikContract, "gainedXp");
  
      let xp = await dystopikContract.xp(charID);
      
      expect(xp).to.equal(xpGiven);
    });

    it("Levels up correctly given sufficient xp", async () => {
      const xpGiven = 100;
      const expectedLvl = 2;
  
      let xpTxn = await dystopikContract.gainXp(charID, xpGiven);
      await xpTxn.wait();

      const beforeXp = await dystopikContract.xp(charID);
      const beforeLvl = await dystopikContract.level(charID);
      const xp2LevelUp = await dystopikContract.nextLevelXp(beforeLvl);

      let lvlUpTxn = await dystopikContract.levelUp(charID);
      await lvlUpTxn.wait();

      expect(lvlUpTxn).to.emit(dystopikContract, "leveledUp");

      const currentXp = await dystopikContract.xp(charID);
      const currentLvl = await dystopikContract.level(charID);

      expect(currentLvl).to.equal(expectedLvl);
      expect(currentXp).to.equal(beforeXp - xp2LevelUp);
    });
  });

  describe("Attributes Interface", async () => {
    let attributesContract;
    let tokenID = 1;
    let charType = 1;
    const strength = 5, speed = 5, fortitude = 5, technical = 2, instinct = 2, dexterity = 3, luck = 3;

    beforeEach(async () => {
      const attributesFactory = await ethers.getContractFactory("Attributes");
      attributesContract = await attributesFactory.deploy(dystopikContract.address);

      await dystopikContract.setAttributesInterface(attributesContract.address);

      mintTxn = await dystopikContract.createCharacter(charType);
      await mintTxn.wait();
    });

    it("Gets the attributes of a player's character", async () => {
      let txn = await attributesContract.setInitAttributes(tokenID, strength, speed, fortitude, technical, instinct, dexterity, luck);
      
      txn = await dystopikContract.getAttributes(tokenID);
      expect(txn[0]).to.equal(strength);
      expect(txn[1]).to.equal(speed);
      expect(txn[2]).to.equal(fortitude);
      expect(txn[3]).to.equal(technical);
      expect(txn[4]).to.equal(instinct);
      expect(txn[5]).to.equal(dexterity);
      expect(txn[6]).to.equal(luck);
    });

    it("Outputs the correct tokenURI", async () => {
      let txn = await attributesContract.setInitAttributes(tokenID, strength, speed, fortitude, technical, instinct, dexterity, luck);
      await txn.wait();

      txn = await dystopikContract.tokenURI(tokenID);
      console.log(txn);
    });
  });

});
