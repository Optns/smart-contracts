const { expect } = require("chai")

module.exports = {
    escrowFails: (optionContract) => {
        return () => {
            optionContract.escrow()
            .then(() => {
                expect(true).equal(false)
            })
            .catch(error => {
                expect(error.message).to.include(`VM Exception while processing transaction: reverted with reason string`)
            })
        }
    },
    cancellationFails: (optionContract) => {
        return () => {
            optionContract.cancel()
            .then(() => {
                expect(true).equal(false)
            })
            .catch(error => {
                expect(error.message).to.include(`VM Exception while processing transaction: reverted with reason string`)
            })
        }
    },
    expireFails: (optionContract) => {
        return () => {
            optionContract.expire()
            .then(() => {
                expect(true).equal(false)
            })
            .catch(error => {
                expect(error.message).to.include(`VM Exception while processing transaction: reverted with reason string`)
            })
        }
    },
    executeFails: (optionContract) => {
        return () => {
            optionContract.execute()
            .then(() => {
                expect(true).equal(false)
            })
            .catch(error => {
                expect(error.message)
                expect(error.message).to.include(`VM Exception while processing transaction: reverted with reason string`)
            })
        }
    },
    expectedStatus: (status, optionContract) => {
        return async () => {
            const statusResponse = await optionContract.getStatus();
            expect(statusResponse).equal(status)
        }
    }
}

