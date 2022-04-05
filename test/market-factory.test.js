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
    tokenOut: testUSD.address,
    tokenIn: testOptn.address,
    amountPow: 1,
  }
})

describe('Orderbook factory', () => {
  let contract
  let contractAddress

  before(async () => {
    const transaction = await orderBookFactory.createMarket(orderBookStandard)
    await transaction.wait()

    const pair = pairHash(orderBookStandard.tokenIn, orderBookStandard.tokenOut)

   contractAddress = await orderBookFactory.getMarketAddress(pair)
    
    contract = await OptionFactory.attach(contractAddress)
  })

  it('market address is valid', () => {
    expect(ethers.utils.isAddress(contractAddress)).to.equal(true)
    expect(contractAddress).to.not.equal('0x0000000000000000000000000000000000000000')
  })

  it('attach sell option factory to market clone address', async () => {
    describe(
      'market factory',
      optionFactoryTest(contract, orderBookStandard, owner),
    )
  })
});

const pairHash = (tokenIn, tokenOut) => {
  return ethers.utils.solidityKeccak256(["bytes20", "bytes20"], [tokenIn, tokenOut])
}