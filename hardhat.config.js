require("@nomiclabs/hardhat-waffle");
require("@openzeppelin/hardhat-upgrades")
// require("hardhat-gas-reporter");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const RINKEBY_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY
const INFURA_PROJECT_ID = process.env.INFURA_PROJECT_ID

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: '0.8.2',
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "1337"        // Any network (default: none)
    },
    rinkeby: {
      network_id: 4,
      url: `https://rinkeby.infura.io/v3/${INFURA_PROJECT_ID}`,
      accounts: [RINKEBY_PRIVATE_KEY],
      gas: 2_100_000,
      gasPrice: 8_000_000_000,
      saveDeployments: true,
    }
  }
  // gasReporter: {
  //   currency:'USD',
  // }
};
