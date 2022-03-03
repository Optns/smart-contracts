const { ethers, upgrades } = require('hardhat')

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  let TestUSD
  let TestOptn
  let testUSD
  let testOptn
  let owner, holder1, holders

  const proxyArgs = {
    kind: 'uups',
  }

  ;[owner, holder1, ...holders] = await ethers.getSigners()

  // We get the contract to deploy
  // get contract factory

  TestUSD = await ethers.getContractFactory('TestUSD')
  TestOptn = await ethers.getContractFactory('TestOptn')

  // deploy contracts
  testUSD = await upgrades.deployProxy(TestUSD, proxyArgs)
  testOptn = await upgrades.deployProxy(TestOptn, proxyArgs)

  console.log('testUSD deployed to:', testUSD.address)
  console.log('testOptn deployed to:', testOptn.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
