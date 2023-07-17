const customToken = artifacts.require("customToken");
const BN = require("bn.js");

const bnObject = new BN("100");

const numberValue = bnObject.toNumber();

console.log(numberValue);

contract("customToken", (accounts) => {
  let token;
  const account1 = accounts[0];
  const account2 = accounts[1];

  beforeEach(async () => {
    token = await customToken.new(
      "My Token",
      "MTK",
      18,
      1000000,
      2,
      3,
      1,
      account1
    );
  });

  it("should have the correct token details", async () => {
    const name = await token.name();
    const symbol = await token.symbol();
    const decimals = await token.decimals();

    assert.equal(name, "My Token", "Token should have the correct name");
    assert.equal(symbol, "MTK", "Token should have the correct symbol");
    assert.equal(decimals, 18, "Token should have the correct decimals");
  });

  it("should transfer tokens correctly", async () => {
    const initialBalance2 = await token.balanceOf(account2);
    const transferAmount = 100;
    const taxPercentage = await token.buyTaxPercentage;

    await token.transferFrom(account1, account2, 50);

    const finalBalance2 = await token.balanceOf(account2);
  });

  it("should convert tax amount to ETH correctly", async () => {
    const taxAmount = 100;
    let convertedAmount = await token.convertToEth(taxAmount);
    const bnObject = new BN(convertedAmount);
    const numberValue = bnObject.toNumber();
    const weiAmountc = BigInt(numberValue);
    convertedAmount = Number(weiAmountc) / 1e18;
    const weiAmount = BigInt(taxAmount);
    const etherAmount = Number(weiAmount) / 1e18;
    assert.equal(
      convertedAmount.toString(),
      etherAmount.toString(),
      "Conversion to ETH should be calculated correctly"
    );
  });
});
