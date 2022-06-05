const { expect } = require("chai");
const { ethers } = require("hardhat");

async function deploy(name, ...params) {
    const newContract = await ethers.getContractFactory(name);
    return await newContract.deploy(...params).then(c => c.deployed());
}

describe("Weapons", () => {
    beforeEach(async () => {
        this.wpnContract = await deploy("Weapons");
        this.manifestContract = await deploy("WeaponManifest");
        this.wpnContract.setManifestInterface(this.manifestContract.address);
        this.accounts = await ethers.getSigners();
    });

    it("Rejects minting invalid wpn variants", async () => {
        const invVariant1 = 0, invVariant2 = 4;

        await expect(
            this.wpnContract.createWeapon(invVariant1)
        ).to.be.revertedWith("Invalid Weapon Variant");

        await expect(
            this.wpnContract.createWeapon(invVariant2)
        ).to.be.revertedWith("Invalid Weapon Variant");
    })

    it("Creates all weapons correctly", async () => {
        const totalVariants = 3;
        const keyNames = [
            "variantID",
            "name", 
            "description",
            "imageURI",
            "damageType",
            "limitedSupply",
            "limit",
            "cost",
            "damageMin",
            "weight",
            "damageMax",
            "critchance"
        ]

        for(i = 0; i < totalVariants.length; i++){
            let wpnVariant = i+1, wpnID = i+1;
            let attributeKey;
            let manifestTxn = await this.manifestContract.idToWpn(wpnVariant);
            let wpnTxn = await this.wpnContract.createWeapon(wpnVariant);
            let wpnStats = await this.wpnContract.idToStats(wpnID);

            expect(wpnTxn).to.emit(this.wpnContract, "weaponMinted");

            for(j = 0; ij< keyNames.length; j++){
                attributeKey = keyNames[j];
                expect(wpnStats[attributeKey]).to.equal(manifestTxn[attributeKey]);
            }
        }
    });

    it("Creates the correct tokenURI", async () => {
        const wpnVariant = 1;
        const wpnID = 1;
        let txn = await this.wpnContract.createWeapon(wpnVariant);
        txn = await this.wpnContract.tokenURI(wpnID);
        console.log(txn);
    });
});