const OddEvenGame = artifacts.require("OddEvenGame");

contract("OddEvenGame", (accounts) => {
  let gameInstance;
  const player = accounts[0];
  const participationFee = web3.utils.toWei("0.1", "ether");
  const bettingLimit = web3.utils.toWei("1", "ether");

  beforeEach(async () => {
    gameInstance = await OddEvenGame.new(participationFee, bettingLimit);
  });

  it("should place a bet and emit BetPlaced event", async () => {
    const Outcome = {
      Even: 0,
      Odd: 1,
    };

    const outcome = Outcome.Even; // Use Outcome.Even or Outcome.Odd
    const amount = web3.utils.toWei("0.2", "ether");

    await gameInstance.placeBet(outcome, { from: player, value: amount });
  });

  it("should distribute winnings correctly and emit GameResult event", async () => {
    const Outcome = {
      Even: 0,
      Odd: 1,
    };

    const outcome = Outcome.Even; // Use Outcome.Even or Outcome.Odd
    const amount = web3.utils.toWei("0.2", "ether");

    await gameInstance.placeBet(outcome, { from: player, value: amount });

    await gameInstance.distributeWinnings(0);
  });
});
