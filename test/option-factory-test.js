const { expect } = require('chai')
const { ethers } = require('hardhat')
const optionTest = require('./option-test')
const { escrowTest, cancel } = require('./transactions-test')

const optionFactoryTest = (orderbook, orderBookStandard, owner) => {
  return () => {
    let Option

    before(async () => {
      Option = await ethers.getContractFactory('Option')
    })

    it('initialize sell option factory again failed', async () => {
      orderbook
        .__optionFactory_init(orderBookStandard)
        .then(() => {
          expect(true).equal(false)
        })
        .catch((error) => {
          const errorMessage = 'cannot override "implementation","tokenOut","tokenIn","amountPow" (operation="overrides", overrides=["implementation","tokenOut","tokenIn","amountPow"], code=UNSUPPORTED_OPERATION, version=contracts/5.5.0)'
          expect(error.message).to.equal(errorMessage)
        })
    })

    describe('check orderbook standards', () => {
      let orderbookStandardResponse;
      before( async () => {
        orderbookStandardResponse = await orderbook.getOrderbookStandard()
      })
      it("match tokenIn", () => {
        expect(orderbookStandardResponse.tokenIn).to.equal(orderBookStandard.tokenIn)
      })
      it("match tokenOut", () => {
        expect(orderbookStandardResponse.tokenOut).to.equal(orderBookStandard.tokenOut)
      })
      it("match implementation", () => {
        expect(orderbookStandardResponse.implementation).to.equal(orderBookStandard.implementation)
      })
      it("match amountPow", () => {
        expect(orderbookStandardResponse.amountPow).to.equal(orderBookStandard.amountPow)
      })
    })

    describe('Clone orderbook', () => {
      const optn = {
        premium: 400,
        strikePrice: 4000,
        duration: 0
      }

      let optionContract, args

      let baseToken, token, amount
      let optionFactory, OptionFactory
      let buyer

      let initialContractBalance
      let optionStandard

      before(async () => {
        // get contract factory
        TestUSD = await ethers.getContractFactory('TestUSD')
        TestOptn = await ethers.getContractFactory('TestOptn')
        ;[_, buyer] = await ethers.getSigners()

        OptionFactory = await ethers.getContractFactory('OptionFactory')
        optionFactory = OptionFactory.attach(orderbook.address)
        baseToken = TestUSD.attach(orderBookStandard.tokenOut)
        token = TestOptn.attach(orderBookStandard.tokenIn)

        await token.mint()
        await baseToken.mint()

        await baseToken.connect(buyer).mint()
        await token.connect(buyer).mint()
      })

      beforeEach(async () => {
        const transaction = await orderbook.cloneOptionContract(optn)
        const receipt = await transaction.wait()

        const event = receipt.events.filter((event) => {
          return event.event === 'OptionEvent'
        })[0]

        args = event.args
        optionContract = await Option.attach(args[0])
        optionStandard = await optionContract.getOptionStandard()

        // escrow
        initialContractBalance = await token.balanceOf(optionContract.address)
        await token.approve(optionContract.address, optionStandard.amount)

        await optionContract.escrow()
      })

      it('check option params', () => {
        describe('option params', () => {
          it('owner is seller', () => {
            expect(args[1].toLowerCase()).to.equal(owner.address.toLowerCase())
          })

          it(`option address is valid`, () => {
            expect(ethers.utils.isAddress(args[0])).equal(true)
            expect(args[0]).to.not.equal('0x0000000000000000000000000000000000000000')
          })

          describe(
            `option contract`,
            optionTest(optionContract, optn, owner, optionStandard)
          )
        })
      })
      it(`escrow option contract`, () => {
        describe(
          `Escrow option contract`,
          escrowTest(optionContract, initialContractBalance, optionStandard.amount, token, baseToken, buyer, owner)
        )
      })

      it('non seller cancel contract fail', () => {
        optionContract
          .connect(buyer)
          .cancel()
          .then(() => {
            expect(true).equal(false)
          })
          .catch((error) => {
            expect(error.message).equal(
              "VM Exception while processing transaction: reverted with reason string 'Access: caller is not seller'"
            )
          })
      })

      it(`cancel option contract`, () => {
        describe(
          `cancelling  contract`,
          cancel(optionContract, optionStandard.amount, token, owner)
        )
      })
    })
  }
}

module.exports = optionFactoryTest
