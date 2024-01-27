const HDWalletProvider = require("@truffle/hdwallet-provider");
const PrivateKeyProvider = require("@truffle/hdwallet-provider");
const privateKeys = ["8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63", "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3", "ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f"];
const nodes = ["http://localhost:21001", "http://localhost:21001", "http://localhost:21002", "http://localhost:21003", "http://localhost:8545"];

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*"
    },
    wallet1: {
      provider: () => new HDWalletProvider(privateKeys[0], nodes[0]),
      network_id: "*"
    },
    wallet2: {
      provider: () => new HDWalletProvider(privateKeys[1], nodes[1]),
      network_id: "*"
    },
    wallet3: {
      provider: () => new HDWalletProvider(privateKeys[2], nodes[2]),
      network_id: "*"
    }
  }
};
