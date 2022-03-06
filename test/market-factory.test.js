const { ethers, upgrades } = require('hardhat')
const { expect } = require('chai')
const optionFactoryTest = require('./option-factory-test')

let owner
let OrderBookFactory, OptionFactory, Option
let orderBookFactory, optionFactory, option
let orderBookStandard

let TestUSD, TestOptn
let testUSD, testOptn

const OptionType = {
  PUT: 0,
  CALL: 1
}

const proxyArgs = {
  kind: 'uups',
}

before('contract factory', async () => {
  ;[owner] = await ethers.getSigners()

  OrderBookFactory = await ethers.getContractFactory('OrderBookFactory')
  OptionFactory = await ethers.getContractFactory('OptionFactory')
  Option = await ethers.getContractFactory('Option')

  orderBookFactory = await OrderBookFactory.deploy()
  optionFactory = await OptionFactory.deploy()
  option = await Option.deploy()

  // get contract factory
  TestUSD = await ethers.getContractFactory('TestUSD')
  TestOptn = await ethers.getContractFactory('TestOptn')

  // deploy contracts
  testUSD = await upgrades.deployProxy(TestUSD, proxyArgs)
  testOptn = await upgrades.deployProxy(TestOptn, proxyArgs)

  orderBookFactory.__orderBookFactory_init(optionFactory.address)

  orderBookStandard = {
    implementation: option.address,
    baseCurrency: testUSD.address,
    token: testOptn.address,
    amount: 2121212,
    durationInBlock: 312321313,
  }
})

describe('Orderbook factory', () => {
  let contract
  let args

  before(async () => {
    const transaction = await orderBookFactory.createMarket(orderBookStandard)
    const receipt = await transaction.wait()

    const event = receipt.events.filter((event) => {
      return event.event === 'OrderBookCreated'
    })[0]

    args = event.args
    contract = await OptionFactory.attach(args[0])
  })

  it('market address is valid', () => {
    expect(ethers.utils.isAddress(args[0])).to.equal(true)
    expect(args[0]).to.not.equal('0x0000000000000000000000000000000000000000')
  })

  it('market clone event token', () => {
    expect(args[1].toLowerCase()).to.equal(
      orderBookStandard.token.toLowerCase(),
    )
  })

  it('market clone event base currency', () => {
    expect(args[2].toLowerCase()).to.equal(
      orderBookStandard.baseCurrency.toLowerCase(),
    )
  })

  it('attach sell option factory to market clone address', async () => {
    describe(
      'Put market factory',
      optionFactoryTest(contract, orderBookStandard, owner, OptionType.PUT),
    )

    describe(
      'Call market factory',
      optionFactoryTest(contract, orderBookStandard, owner, OptionType.CALL),
    )
  })
});