const { expect } = require('chai')
const { ethers } = require('hardhat')
const {
  expireFails,
  escrowFails,
  cancellationFails,
  executeFails,
  expectedStatus,
} = require('./failing-transactions-test')

const Status = {
  INIT: 0,
  ESCROWED: 1,
  BOUGHT: 2,
  CLOSED: 3,
}

const escrow = (optionContract, initialContractBalance, amount, escrowToken, baseToken, buyer, seller) => {
  return () => {
    it('balance incremented to amount', async () => {
      const newBalance = await escrowToken.balanceOf(optionContract.address)
      expect(newBalance.toString()).equal(initialContractBalance.add(amount).toString())
    })

    it('new status is ESCROWED', expectedStatus(Status.ESCROWED, optionContract))

    it('expire fails before buying', expireFails(optionContract))

    it('execute fails before buying', executeFails(optionContract))

    describe('Buy option', buy(optionContract, baseToken, buyer, amount, seller))

    // describe('Expire option', expire(optionContract, escrowToken, seller, amount))
  }
}

const buy = (optionContract, baseToken, buyer, amount, seller) => {
  return () => {
    let premium
    let sellerBaseTokenInitialPrice, sellerBaseTokenAfterPrice
    let blockNumber
    before(async () => {
      sellerBaseTokenInitialPrice = await baseToken.balanceOf(seller.address)
      await baseToken.connect(buyer).approve(optionContract.address, amount)
      const transaction = await optionContract.connect(buyer).buy()
      blockNumber = transaction.blockNumber
      sellerBaseTokenAfterPrice = await baseToken.balanceOf(seller.address)
      const option = await optionContract.getOrder()
      premium = option.premium
    })

    it('new status is BOUGHT', expectedStatus(Status.BOUGHT, optionContract))

    it('cancel contract after bought failed', cancellationFails(optionContract))

    it('escrow fails after bought', escrowFails(optionContract))

    it('buyer is incremented with premium', () => {
      expect(sellerBaseTokenAfterPrice.toString()).equal(sellerBaseTokenInitialPrice.add(premium).toString())
    })

    // it('new initializationBlock is set', async () => {
    //   const initializationBlock = await optionContract.getInitializationBlock()
    //   expect(initializationBlock).equal(blockNumber)
    // })
  }
}

const expire = (optionContract, escrowToken, seller, amount) => {
  let sellerEscrowTokenInitialPrice, sellerEscrowTokenAfterPrice

  return () => {
    before(async () => {
      const holders = await ethers.getSigners()
      sellerEscrowTokenInitialPrice = await escrowToken.balanceOf(seller.address)
      await optionContract.connect(holders[2]).expire()
      sellerEscrowTokenAfterPrice = await escrowToken.balanceOf(seller.address)
    })

    it('status changed to CLOSED', expectedStatus(Status.CLOSED, optionContract))

    it('seller refunded after contract expired', () => {
      expect(sellerEscrowTokenAfterPrice).equal(sellerEscrowTokenInitialPrice.add(amount))
    })
  }
}

const cancel = (optionContract, amount, escrowToken, seller) => {
  return () => {
    let sellerInitialBalance
    before(async () => {
      sellerInitialBalance = await escrowToken.balanceOf(seller.address)
      await optionContract.cancel()
    })

    it('balance of seller is incremented', async () => {
      let newSellerBalance = await escrowToken.balanceOf(seller.address)
      expect(newSellerBalance.toString()).equal(sellerInitialBalance.add(amount).toString())
    })

    it('status closed', expectedStatus(Status.CLOSED, optionContract))

    it('escrow fails after canellation', escrowFails(optionContract))

    it('buy fails after cancellation', cancellationFails(optionContract))

    it('expire fails after cancellation', expireFails(optionContract))

    it('execute fails after cancellation', executeFails(optionContract))
  }
}

module.exports = {
  escrowTest: escrow,
  cancel: cancel,
}
