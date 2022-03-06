const { expect } = require("chai")

const Status = {
    INIT: 0,
    ESCROWED: 1,
    BOUGHT: 2,
    CLOSED: 3
}

const optionTest = (optionContract, optn, seller, orderbookAddress, optionType) => {
    return () => {
        let OptionFactory
        before(async () => {
            OptionFactory = await ethers.getContractFactory('OptionFactory')
        })
        
        it("failed to initialize option contract again", async () => {
            const changedOptn = {...optn, premium: 0, strikePrice: 1}
            await optionContract.__option_init(
                changedOptn,
                seller,
                orderbookAddress,
                optionType
            )
            .then(() => expect(true).equal(false))
            .catch(error => {
                const errorMessage = "VM Exception while processing transaction: reverted with reason string 'Initializable: contract is already initialized'"
                expect(error.message).to.equal(errorMessage)
            })
        })

        it("status is INIT", async () => {
            const status = await optionContract.getStatus();
            expect(status).equal(Status.INIT)
        })

        it("get order", () => {
            describe(`Check order state of ${optionType === 0 ? 'PUT' : 'CALL'} option contract after initialization`, () => {
                let order;
                before(async () => {
                    order = await optionContract.getOrder()
                })

                it("premium is optn.premium", () => {
                    expect(order.optn.premium).to.equal(optn.premium)
                })

                it("strike price is optn.strikePrice", () => {
                    expect(order.optn.strikePrice).to.equal(optn.strikePrice)
                })

                it("seller is owner", () => {
                    expect(order.seller).to.equal(seller)
                })

                it("buyer is addess(0)", () => {
                    expect(order.buyer).to.equal('0x0000000000000000000000000000000000000000')
                })

                it("initializationBlock is 0", () => {
                    expect(order.initializationBlock).to.equal(0)
                })
            })
        })

        it("transactions", () => {
            describe("transation methods test ERC20", () => {
                let baseToken, token, amount;
                let optionFactory;
                let seller

                before(async () => {
                    // get contract factory
                    TestUSD = await ethers.getContractFactory('TestUSD');
                    TestOptn = await ethers.getContractFactory('TestOptn');
                    [_, seller] = await ethers.getSigners()

                    optionFactory = await OptionFactory.attach(orderbookAddress)
                    baseToken = await TestUSD.attach(optionFactory.getBaseCurrency())
                    token = await TestOptn.attach(optionFactory.getToken())
                    amount = await optionFactory.getAmount()

                    await token.mint()
                    await baseToken.mint()

                    await baseToken.connect(seller).mint()
                    await token.connect(seller).mint()

                })
                if (optionType === 0) {
                    it("Put contract transaction", () => {
                        describe("escrow token to contract", () => {
                            let initialContractBalance
                            before(async () => {
                                initialContractBalance = await token.balanceOf(optionContract.address)
                                await token.approve(optionContract.address, amount)
                                await optionContract.escrow()
                            })

                            it("check if balance incremented", async () => {
                                const newBalance = await token.balanceOf(optionContract.address)
                                expect(newBalance.toString()).equal(initialContractBalance.add(amount).toString())
                            })

                            it("new status ESCROWED", async () => {
                                const status = await optionContract.getStatus();
                                expect(status).equal(Status.ESCROWED)
                            })
                        })
                    })
                } 
                else if (optionType == 1) {
                    it("Call contract transaction", () => {
                        describe("escrow base token to contract", () => {
                            let initialContractBalance
                            before(async () => {
                                initialContractBalance = await baseToken.balanceOf(optionContract.address)
                                await baseToken.approve(optionContract.address, amount)
                                await optionContract.escrow()
                            })

                            it("check if balance incremented", async () => {
                                const newBalance = await baseToken.balanceOf(optionContract.address)
                                expect(newBalance.toString()).equal(initialContractBalance.add(amount).toString())
                            })

                            it("new status ESCROWED", async () => {
                                const status = await optionContract.getStatus();
                                expect(status).equal(Status.ESCROWED)
                            })
                        })
                    })
                }
            })
        })
    }
}

module.exports = optionTest