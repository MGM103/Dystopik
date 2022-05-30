const hre = require("hardhat");

async function main() {
  const imageURIs = [
    "https://i.pinimg.com/564x/f7/cc/b5/f7ccb5a281a6c12773eb486b369d7f89.jpg",
    "https://i.pinimg.com/564x/55/b9/04/55b9046000c50ce93fb17da7c2abe6a7.jpg",
    "https://i.pinimg.com/564x/dd/6f/47/dd6f4703cd14c56af1fab2cbb6e5eb7c.jpg"
  ]
  const charType = 1;
  const strength = 5, speed = 5, fortitude = 5, technical = 2, instinct = 2, dexterity = 3, luck = 3;
  const tokenID = 1;

  const dystopikFactory = await hre.ethers.getContractFactory("Dystopik");
  const dystopikContract = await dystopikFactory.deploy(imageURIs);
  await dystopikContract.deployed();
 
  console.log("Dystopik deployed to:", dystopikContract.address);

  const attributesFactory = await ethers.getContractFactory("Attributes");
  const attributesContract = await attributesFactory.deploy(dystopikContract.address);
  await attributesContract.deployed();

  console.log("Attributes deployed to:", attributesContract.address);

  console.log("Setting attribute interface for dystopik contract...")
  await dystopikContract.setAttributesInterface(attributesContract.address);

  console.log("Minting character...")
  let mintTxn = await dystopikContract.createCharacter(charType);
  await mintTxn.wait();

  console.log("Setting attributes for character...")
  let attributesTxn = await attributesContract.setInitAttributes(tokenID, strength, speed, fortitude, technical, instinct, dexterity, luck);
  await attributesTxn.wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
