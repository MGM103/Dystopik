const { expect } = require("chai");
const { ethers } = require("hardhat");

async function deploy(name, ...params){
    const newContract = await ethers.getContractFactory(name);
    return await newContract.deploy(...params).then(c => c.deployed());
}

describe("WeaponManifest", () => {
    beforeEach(async () => {
        this.manifest = await deploy("WeaponManifest");
        this.accounts = await ethers.getSigners();
    });

    it("Maps weapon type IDs to correct str", async () => {
        let txn;
        const wpnTypeStrs = new Map([
            [1, "Slashing"],
            [2, "Bludgeoning"],
            [3, "Piercing"],
            [4, "Shock"],
            [5, "Explosive"]
        ]);

        for(i = 1; i <= wpnTypeStrs.size; i++) {
            txn = await this.manifest.wpnTypeToString(i);
            expect(txn).to.equal(wpnTypeStrs.get(i));
        }    
    });

    it("Returns correct details for the Baton weapon variant", async () => {
        let txn, attributeKey;
        const batonInfo = new Map([
            ["variantID", 1],
            ["name", "Baton"],
            ["description", "Standard issue police officer protection baton"],
            ["imageURI", "https://media.istockphoto.com/vectors/vector-sketch-telescopic-baton-vector-id493024442?k=6&m=493024442&s=612x612&w=0&h=mdbaLmnSoq4fJtHagvL3uvtHkiW_Pj1a8l9t_PMO1fY="],
            ["damageType", 1],
            ["limitedSupply", false],
            ["limit", 0],
            ["cost", 10],
            ["damageMin", 1],
            ["weight", 2],
            ["damageMax", 5],
            ["critchance", 1]
        ]);

        const attributeKeys = batonInfo.keys();
        txn = await this.manifest.baton();

        for(i = 1; i < batonInfo.size; i++) {
            attributeKey = attributeKeys.next().value;
            expect(txn[attributeKey]).to.equal(batonInfo.get(attributeKey));
        }  
    });

    it("Returns correct details for the Metal Rod weapon variant", async () => {
        let txn, attributeKey;
        const metalRodInfo = new Map([
            ["variantID", 2],
            ["name", "Metal Rod"],
            ["description", "That constuction site doesn't need this"],
            ["imageURI", "https://clipground.com/images/metal-rod-clipart-6.jpg"],
            ["damageType", 2],
            ["limitedSupply", false],
            ["limit", 0],
            ["cost", 5],
            ["damageMin", 1],
            ["weight", 2],
            ["damageMax", 5],
            ["critchance", 1]
        ]);

        const attributeKeys = metalRodInfo.keys();
        txn = await this.manifest.metalRod();

        for(i = 1; i < metalRodInfo.size; i++) {
            attributeKey = attributeKeys.next().value;
            expect(txn[attributeKey]).to.equal(metalRodInfo.get(attributeKey));
        }  
    });

    it("Returns correct details for the Shiv weapon variant", async () => {
        let txn, attributeKey;
        const shivInfo = new Map([
            ["variantID", 3],
            ["name", "Shiv"],
            ["description", "Stick them with the pointy end"],
            ["imageURI", "https://static.wikia.nocookie.net/skyrim_gamepedia/images/b/b6/Shiv.png/revision/latest?cb=20120114155931"],
            ["damageType", 3],
            ["limitedSupply", false],
            ["limit", 0],
            ["cost", 8],
            ["damageMin", 3],
            ["weight", 1],
            ["damageMax", 8],
            ["critchance", 2]
        ]);

        const attributeKeys = shivInfo.keys();
        txn = await this.manifest.shiv();

        for(i = 1; i < shivInfo.size; i++) {
            attributeKey = attributeKeys.next().value;
            expect(txn[attributeKey]).to.equal(shivInfo.get(attributeKey));
        }  
    });
});