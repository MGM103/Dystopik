const hre = require("hardhat");

async function deploy(name, ...params) {
    const newContract = await ethers.getContractFactory(name);
    return await newContract.deploy(...params).then(c => c.deployed());
}

async function main() {
    wpnContract = await deploy("Weapons");
    console.log("Weapon contract deployed to:", wpnContract.address);

    manifestContract = await deploy("WeaponManifest");
    const totalVariants = await manifestContract.totalVariants();
    console.log("Weapon Manifest contract deployed to:", manifestContract.address);

    let txn = await wpnContract.setManifestInterface(manifestContract.address);
    console.log("Manifest interface set in Weapon Contract");

    for(i = 1; i <= totalVariants; i++){
        console.log(`Minting variant ${i}...`);
        let mintTxn = await wpnContract.createWeapon(i);
        await mintTxn.wait();
    }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
