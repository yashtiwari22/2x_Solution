var Nftmint = artifacts.require("./Nftmint.sol");

module.exports = (deployer) => {
  deployer.deploy(Nftmint);
};
