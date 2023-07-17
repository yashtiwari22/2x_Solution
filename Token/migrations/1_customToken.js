var customToken = artifacts.require("./customToken.sol");

module.exports = (deployer) => {
  deployer.deploy(
    customToken,
    "My Token",
    "MTK",
    18,
    1000000,
    2,
    3,
    1,
    "0x86f0615998ecfc25d94f5626ffd012a764e59a2a"
  );
};
