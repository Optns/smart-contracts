const { ethers, upgrades } = require('hardhat')
const { expect } = require('chai')
const optionFactoryTest = require('./option-factory-test')

let owner, holder1, holder2, holders
let OrderBookFactory, OptionFactory, Option
let orderBookFactory, optionFactory, option
let orderBookStandard

before('contract factory', async () => {
  ;[owner, holder1, holder2, ...holders] = await ethers.getSigners()

  OrderBookFactory = await ethers.getContractFactory('OrderBookFactory')
  OptionFactory = await ethers.getContractFactory('OptionFactory')
  Option = await ethers.getContractFactory('Option')

  orderBookFactory = await OrderBookFactory.deploy()
  optionFactory = await OptionFactory.deploy()
  option = await Option.deploy()

  orderBookFactory.__orderBookFactory_init(optionFactory.address)

  orderBookStandard = {
    implementation: option.address,
    baseCurrency: '0x5f4ec3df9cbd43714fe2740f5e3616155c5b8410',
    token: '0x5f4ec3df9cbd43714fe2740f5e3616155c5b8412',
    amount: 2121212,
    durationInBlock: 312321313,
  }
})

describe('orderbook factory', () => {
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
    expect(ethers.utils.isAddress(args[0])).equal(true)
    expect(args[0]).to.not.equal('0x0')
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
      'put option factory',
      optionFactoryTest(contract, orderBookStandard, owner, 0),
    )

    describe(
      'call option factory',
      optionFactoryTest(contract, orderBookStandard, owner, 1),
    )
  })
})
