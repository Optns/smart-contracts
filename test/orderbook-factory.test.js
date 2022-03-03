const { ethers, upgrades } = require('hardhat')
const { expect } = require('chai')
const sellOptionFactoryTest = require('./sell-option-factory-test')

let owner, holder1, holder2, holders
let sellPutOptionOrder, sellCallOptionOrder, sellOptionFactory, orderBookFactory
let orderBookStandard
let SellOptionFactory

before('contract factory', async () => {
  ;[owner, holder1, holder2, ...holders] = await ethers.getSigners()
  const SellPutOptionOrder = await ethers.getContractFactory(
    'SellPutOptionOrder',
  )
  const SellCallOptionOrder = await ethers.getContractFactory(
    'SellCallOptionOrder',
  )
  SellOptionFactory = await ethers.getContractFactory('SellOptionFactory')
  const OrderBookFactory = await ethers.getContractFactory('OrderBookFactory')

  sellPutOptionOrder = await SellPutOptionOrder.deploy()
  sellCallOptionOrder = await SellCallOptionOrder.deploy()
  sellOptionFactory = await SellOptionFactory.deploy()
  orderBookFactory = await OrderBookFactory.deploy()

  orderBookFactory.__orderBookFactory_init(sellOptionFactory.address)

  orderBookStandard = {
    sellPutImp: sellPutOptionOrder.address,
    sellCallImp: sellCallOptionOrder.address,
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
    contract = await SellOptionFactory.attach(args[0])
  })

  it('market address is valid', () => {
    ethers.utils.isAddress(args[0])
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
      'sell option factory',
      sellOptionFactoryTest(contract, orderBookStandard, owner),
    )
  })
})
