var OddEvenGame = artifacts.require("./OddEvenGame.sol");

module.exports = (deployer) => {
  deployer.deploy(
    OddEvenGame,
    web3.utils.toWei("1", "ether"),
    web3.utils.toWei("10", "ether")
  );
};
