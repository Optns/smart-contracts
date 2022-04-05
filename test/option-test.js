const { expect } = require('chai')

const Status = {
  INIT: 0,
  ESCROWED: 1,
  BOUGHT: 2,
  CLOSED: 3,
}

const optionTest = (optionContract, optn, seller, optionStandard) => {
  return () => {

    it('failed to initialize option contract again', async () => {
      const changedOptn = { ...optn, premium: 0, strikePrice: 1 }
      await optionContract
        .__option_init(changedOptn, seller.address, optionStandard)
        .then(() => expect(true).equal(false))
        .catch((error) => {
          const errorMessage =
            "VM Exception while processing transaction: reverted with reason string 'Initializable: contract is already initialized'"
          expect(error.message).to.equal(errorMessage)
        })
    })

    it('get order', () => {
      describe(`Check order state of option contract after initialization`, () => {
        let option
        let contractSeller, contractBuyer
        
        before(async () => {
          option = await optionContract.getOrder()
          contractSeller = await optionContract.getSeller();
          contractBuyer = await optionContract.getBuyer();
        })

        it('premium is optn.premium', () => {
          expect(option.premium).to.equal(optn.premium)
        })

        it('strike price is optn.strikePrice', () => {
          expect(option.strikePrice).to.equal(optn.strikePrice)
        })

        it('seller is owner', () => {
          expect(contractSeller).to.equal(seller.address)
        })

        it('buyer is addess(0)', () => {
          expect(contractBuyer).to.equal('0x0000000000000000000000000000000000000000')
        })
      })
    })
  }
}

module.exports = optionTest
