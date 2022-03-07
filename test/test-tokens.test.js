const { ethers, upgrades } = require('hardhat')
const { expect } = require('chai')

describe('test tokens', () => {
  let TestUSD
  let TestOptn
  let testUSD
  let testOptn
  let owner, holder1, holders

  const proxyArgs = {
    kind: 'uups',
  }

  beforeEach(async () => {
    ;[owner, holder1, ...holders] = await ethers.getSigners()

    // get contract factory
    TestUSD = await ethers.getContractFactory('TestUSD')
    TestOptn = await ethers.getContractFactory('TestOptn')

    // deploy contracts
    testUSD = await upgrades.deployProxy(TestUSD, proxyArgs)
    testOptn = await upgrades.deployProxy(TestOptn, proxyArgs)
  })

  it('is TUSD symbol', async () => {
    const symbol = await testUSD.symbol()
    expect(symbol).equal('TUSD')
  })

  it('is TOPTN symbol', async () => {
    const symbol = await testOptn.symbol()
    expect(symbol).equal('TOPTN')
  })

  describe('mint tokens', () => {
    let ownerTUSDInitialBalance
    let OnwerTOPTNInitialBalance
    const mintTUSDAmount = 100000000000
    const mintTOPTNAmount = 100000000000

    beforeEach(async () => {
      ownerTUSDInitialBalance = await testUSD.balanceOf(owner.address)
      OnwerTOPTNInitialBalance = await testOptn.balanceOf(owner.address)
      await testUSD.mint()
      await testOptn.mint()
    })

    it(`TUSD balance incremented by ${mintTUSDAmount}`, async () => {
      const ownerTUSDbalance = await testUSD.balanceOf(owner.address)
      expect(ownerTUSDbalance).equal(~~ownerTUSDInitialBalance + mintTUSDAmount)
    })

    it(`TOPTN is incremented by ${mintTOPTNAmount}`, async () => {
      const ownerOPTNbalance = await testOptn.balanceOf(owner.address)
      expect(ownerOPTNbalance).equal(
        ~~OnwerTOPTNInitialBalance + mintTOPTNAmount,
      )
    })
  })
})
