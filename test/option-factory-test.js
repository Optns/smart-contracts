const { expect } = require('chai')
const { ethers } = require('hardhat')
const optionTest = require('./option-test')

const optionFactoryTest = (orderbook, orderBookStandard, owner, optionType) => {
  return () => {
    let Option;

    before(async () => {
      Option = await ethers.getContractFactory('Option')
    })

    it('initialize sell option factory again failed', async () => {
      const invalidOrderBookStandard = { ...orderBookStandard, amount: 0 }
      orderbook
        .__optionFactory_init(invalidOrderBookStandard)
        .then(() => {
          expect(true).equal(false)
        })
        .catch((error) => {
          const errorMessage =
            "VM Exception while processing transaction: reverted with reason string 'Initializable: contract is already initialized'"
          expect(error.message).to.equal(errorMessage)
        })
    })

    it('get token from sell option factory', async () => {
      const token = await orderbook.getToken()
      expect(token.toLowerCase()).to.equal(orderBookStandard.token.toLowerCase())
    })

    it('get base currency from sell option factory', async () => {
      const baseCurrency = await orderbook.getBaseCurrency()
      expect(baseCurrency.toLowerCase()).to.equal(
        orderBookStandard.baseCurrency.toLowerCase(),
      )
    })

    it('get amount from sell option factory', async () => {
      const amount = await orderbook.getAmount()
      expect(amount).to.equal(orderBookStandard.amount)
    })

    it('duration in block from sell option factory', async () => {
      const durationInBlock = await orderbook.getDurationInBlock()
      expect(durationInBlock).to.equal(orderBookStandard.durationInBlock)
    })

    it('order book standard from sell option factory', async () => {
      const obs = await orderbook.getOrderBookStandard()
      expect(obs.token.toLowerCase()).to.equal(
        orderBookStandard.token.toLowerCase(),
      )
      expect(obs.baseCurrency.toLowerCase()).to.equal(
        orderBookStandard.baseCurrency.toLowerCase(),
      )
      expect(obs.amount).equal(orderBookStandard.amount)
      expect(obs.durationInBlock).equal(orderBookStandard.durationInBlock)
    })

    describe('Clone orderbook', () => {
      const optn = {
        premium: 400,
        strikePrice: 4000,
      }
      
      let optionContract, args;

      before(async () => {
        const transaction = await orderbook.cloneOptionContract(
          optn,
          owner.address,
          optionType
        )
        const receipt = await transaction.wait()

        const event = receipt.events.filter((event) => {
          return event.event === 'Option'
        })[0]

        args = event.args
        optionContract = await Option.attach(args[0])
      })

      it('owner is seller', () => {
        expect(args[1].toLowerCase()).to.equal(owner.address.toLowerCase())
      })

      it(`option type is ${optionType === 0 ? 'PUT' : 'CALL'}`, () => {
        expect(args[2]).equal(optionType)
      })

      it(`${optionType === 0 ? 'PUT' : 'CALL'} option address is valid`, () => {
        expect(ethers.utils.isAddress(args[0])).equal(true)
        expect(args[0]).to.not.equal('0x0000000000000000000000000000000000000000')
      })

      it(`attach ${optionType === 0 ? 'PUT' : 'CALL'} option contract`, () => {
        describe(`${optionType === 0 ? 'PUT' : 'CALL'} option contract`, optionTest(optionContract, optn, owner.address, orderbook.address, optionType))
      }) 
    })
  }
}

module.exports = optionFactoryTest
