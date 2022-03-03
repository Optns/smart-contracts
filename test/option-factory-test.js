const { expect } = require('chai')
const { ethers } = require('hardhat')

const optionFactoryTest = (contract, orderBookStandard, owner, optionType) => {
  return () => {
    it('initialize sell option factory again failed', async () => {
      const invalidOrderBookStandard = { ...orderBookStandard, amount: 0 }
      contract
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
      const token = await contract.getToken()
      expect(token.toLowerCase()).equal(orderBookStandard.token.toLowerCase())
    })

    it('get base currency from sell option factory', async () => {
      const baseCurrency = await contract.getBaseCurrency()
      expect(baseCurrency.toLowerCase()).equal(
        orderBookStandard.baseCurrency.toLowerCase(),
      )
    })

    it('get amount from sell option factory', async () => {
      const amount = await contract.getAmount()
      expect(amount).equal(orderBookStandard.amount)
    })

    it('duration in block from sell option factory', async () => {
      const durationInBlock = await contract.getDurationInBlock()
      expect(durationInBlock).equal(orderBookStandard.durationInBlock)
    })

    it('order book standard from sell option factory', async () => {
      const obs = await contract.getOrderBookStandard()
      expect(obs.token.toLowerCase()).equal(
        orderBookStandard.token.toLowerCase(),
      )
      expect(obs.baseCurrency.toLowerCase()).equal(
        orderBookStandard.baseCurrency.toLowerCase(),
      )
      expect(obs.amount).equal(orderBookStandard.amount)
      expect(obs.durationInBlock).equal(orderBookStandard.durationInBlock)
    })

    describe('clone contract', () => {
      const optn = {
        premium: 400,
        strikePrice: 4000,
      }
      let args

      before(async () => {
        const transaction = await contract.cloneOptionContract(
          optn,
          owner.address,
          optionType
        )
        const receipt = await transaction.wait()

        const event = receipt.events.filter((event) => {
          return event.event === 'Option'
        })[0]

        args = event.args
      })

      it('owner is seller', () => {
        expect(args[1].toLowerCase()).to.equal(owner.address.toLowerCase())
      })

      it('put option address is valid', () => {
        expect(ethers.utils.isAddress(args[0])).equal(true)
        expect(args[0]).to.not.equal('0x0')
      })

      it(`option type is ${optionType}`, () => {
        expect(args[2]).equal(optionType)
      })
    })
  }
}

module.exports = optionFactoryTest
