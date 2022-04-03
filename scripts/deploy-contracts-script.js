const { ethers, upgrades } = require('hardhat')

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const [deployer] = await ethers.getSigners()

  console.log("Deploying contracts with the account:", deployer.address); 

  // We get the contract to deploy
  // get contract factory

  const OrderBookFactory = await ethers.getContractFactory('OrderBookFactory')
  const OptionFactory = await ethers.getContractFactory('OptionFactory')
  const Option = await ethers.getContractFactory('Option')

  const orderBookFactory = await OrderBookFactory.deploy()
  await orderBookFactory.deployed()

  const optionFactory = await OptionFactory.deploy()
  await optionFactory.deployed()

  const option = await Option.deploy()
  await option.deployed()

  console.log("orderBookFactory address", orderBookFactory.address)
  console.log("optionFactory address", optionFactory.address)
  console.log("option address", option.address)

  await orderBookFactory.__orderBookFactory_init(optionFactory.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
