const { ethers, upgrades } = require("hardhat")
const { assert, expect } = require("chai")

before("get factory", async () => {
    [this.owner, this.holder1, this.holder2, ...this.holders] = await ethers.getSigners();
    this.Optn = await ethers.getContractFactory("Optn")
    this.OptnV2 = await ethers.getContractFactory("OptnV2")
    this.optn = await upgrades.deployProxy(this.Optn, { kind: 'uups' })
})

it("is correct token name ", async () => {
    assert.equal(await this.optn.name(), "Option")
})

it("mint token", async () => {
    const minting = await this.optn.mint(this.owner.address)
    const ownerBalance = await this.optn.balanceOf(this.owner.address)
    const totalSupply = await this.optn.totalSupply()

    expect(totalSupply).to.equal(ownerBalance)
})

it("check upgradability", async () => {
    const optnv2 = await upgrades.upgradeProxy(this.optn, this.OptnV2)
    assert.equal(this.optn.address, optnv2.address)
    assert.equal(await optnv2.version(), 2)
})