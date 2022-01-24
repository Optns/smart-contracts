const { ethers, upgrades } = require("hardhat")
const { assert } = require("chai")

before("get factory", async () => {
    this.Optn = await ethers.getContractFactory("Optn")
    this.OptnV2 = await ethers.getContractFactory("OptnV2")
})

it("deploy optn token contract", async () => {
    const optn = await upgrades.deployProxy(this.Optn, { kind: 'uups' })
    assert(await optn.name() === "Option")
    const supply = optn.totalSupply();

    const optnv2 = await upgrades.upgradeProxy(optn, this.OptnV2)
    assert(optn.address === optnv2.address)
    assert(await optnv2.version() === "v2")
    
    await optnv2.mintForInvestor()
    assert(supply + BigInt(10**4 * (10**18) === await optnv2.totalSupply()))

})