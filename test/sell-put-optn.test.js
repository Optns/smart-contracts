// const { ethers, upgrades } = require("hardhat")
// const { assert, expect } = require("chai")

// beforeEach("distribute test token", async () => {
//     [this.owner, this.holder1, this.holder2, ...this.holders] = await ethers.getSigners();
//     this.Token = await ethers.getContractFactory("Optn")
//     this.token = await upgrades.deployProxy(this.Token, { kind: 'uups' })
//     this.tusd = await upgrades.deployProxy(this.Token, { kind : 'uups' })

//     this.token.mint(this.owner.address)
//     this.tusd.mint(this.holder1.address)
// })

// beforeEach("create sell put option contract", async () => {
//     this.SellPutOption = await ethers.getContractFactory("SellPutOptn")
//     this.contractParams = {
//         durationInBlock: 1,
//         premium: 15,
//         strikePrice: 20,
//         token: this.token.address
//     }
//     this.sellPutOption = await this.SellPutOption.deploy(this.contractParams)
// })

// beforeEach("set gas token addess", async () => {
//     await this.sellPutOption.setGasToken(this.tusd.address)
// })

// beforeEach("escrow funds", async () => {
//     this.amount = await this.token.balanceOf(this.owner.address)
//     await this.token.approve(this.sellPutOption.address, this.amount)
//     await this.sellPutOption.escrowFunds(this.amount)
// })

// it("check balance", async () => {
//     const testTokenContractBalance = await this.token.balanceOf(this.sellPutOption.address)
//     assert.equal(this.amount.toString(), testTokenContractBalance.toString())
// })

// it("check contract optn param", async () => {
//     [durationInBlock, premium, strikePrice, token] = await this.sellPutOption.viewOptn();
//     assert.equal(durationInBlock, this.contractParams.durationInBlock)
//     assert.equal(premium, this.contractParams.premium)
//     assert.equal(strikePrice, this.contractParams.strikePrice)
//     assert.equal(token, this.contractParams.token)
// })

// it("check ownership", async () => {
//     assert.equal(this.owner.address, await this.sellPutOption.getSeller())
// })

// it("teriminate contract", () => {
//     describe('terminating contract', () => {
//         beforeEach("terminate", async () => {
//             this.sellerInitialBalance = await this.token.balanceOf(this.owner.address)
//             this.contractBalanceBeforeTermination = await this.token.balanceOf(this.sellPutOption.address)
//             await this.sellPutOption.terminateContract()
//         })

//         it("contract debited", async () => {
//             const testTokenContractBalance = await this.token.balanceOf(this.sellPutOption.address)
//             assert.equal(0, testTokenContractBalance.toNumber())
//         })

//         it("seller credited", async () => {
//             const sellerAfterBalance = await this.token.balanceOf(this.owner.address)
//             assert.equal(
//                 this.contractBalanceBeforeTermination.add(this.sellerInitialBalance).toString(),
//                 sellerAfterBalance.toString()
//             )
//         })
//     });
// })

// it("pay premium", () => {
//     describe("pay premium", () => {
//         beforeEach("paying premium", async () => {
//             this.ownerInitialUsdBalance = await this.tusd.balanceOf(this.owner.address)

//             await this.tusd.connect(this.holder1)
//             .approve(this.sellPutOption.address, this.contractParams.premium)

//             await this.sellPutOption.connect(this.holder1).payPremium()

//             this.ownerFinalUsdBalance = await this.tusd.balanceOf(this.owner.address)
//         })

//         it("check if seller is credited", () => {
//             assert.equal(
//                 this.ownerFinalUsdBalance.toString(),
//                 this.ownerInitialUsdBalance.add(this.contractParams.premium).toString()
//             )
//         })

//         it("check buyer", async () => {
//             const buyer = await this.sellPutOption.getBuyer()
//             assert.equal(buyer, this.holder1.address)
//         })

//         it("terminating sold contract", async () => {
//             //expect(await this.sellPutOption.terminateContract()).to.be.an('Error')
//         })

//         it("expire contract", () => {
//             describe("expire contract", () => {
//                 beforeEach("expire", async () => {
//                     this.ownerInitialBalance = await this.token.balanceOf(this.owner.address)
//                     this.contractInitialBalance = await this.token.balanceOf(this.sellPutOption.address)
//                     await this.sellPutOption.expireContract();
//                     this.ownerFinalBalance = await this.token.balanceOf(this.owner.address)
//                 })

//                 it("check if owner credited after expiry", () => {
//                     assert.equal(this.ownerFinalBalance.toString(), this.ownerInitialBalance.add(this.contractInitialBalance).toString())
//                 })
//             })
//         })
//     })
// })
