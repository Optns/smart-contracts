const { ethers, upgrades } = require("hardhat")
const { assert, expect } = require("chai")

beforeEach('contract factory', async () => {
    [this.owner, this.holder1, this.holder2, ...this.holders] = await ethers.getSigners();
    this.SellPutOptionOrder = await ethers.getContractFactory("SellPutOptionOrder")
    this.SellCallOptionOrder = await ethers.getContractFactory("SellCallOptionOrder")
    this.SellOptionFactory = await ethers.getContractFactory("SellOptionFactory")
    this.OrderBookFactory = await ethers.getContractFactory("OrderBookFactory")
})

beforeEach(async () => {
    this.sellPutOptionOrder = await this.SellPutOptionOrder.deploy()
    this.sellCallOptionOrder = await this.SellCallOptionOrder.deploy()
    this.sellOptionFactory = await this.SellOptionFactory.deploy()
    this.orderBookFactory = await this.OrderBookFactory.deploy()

    this.orderBookFactory.__orderBookFactory_init(this.sellOptionFactory.address)
})

beforeEach(async () => {
    this.orderBookStandard = {
        sellPutImp: this.sellPutOptionOrder.address,
        sellCallImp: this.sellCallOptionOrder.address,
        baseCurrency: "0x5f4ec3df9cbd43714fe2740f5e3616155c5b8410",
        oracle: "0x5f4ec3df9cbd43714fe2740f5e3616155c5b8411",
        token: "0x5f4ec3df9cbd43714fe2740f5e3616155c5b8412"
    }
    await this.orderBookFactory.createMarket(this.orderBookStandard)
})

it("order book", async () => {
    this.orderbooks = await this.orderBookFactory.getOrderBooks()
    expect(this.orderbooks).to.be.an('array')
})

it("create option order", async () => {
    const orderAddress = this.orderbooks[0]
    const optn = {
        durationInBlock: 10000,
        premium: 103032,
        strikePrice: 3231313,
        amount: 323232
    }

    const contract = await ethers.getContractAt("SellOptionFactory", orderAddress);

    await contract.cloneSellPutContract(optn, this.owner.address)
})