const NFTMintingContract = artifacts.require("./Nftmint.sol");

contract("NFTMintingContract", (accounts) => {
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await NFTMintingContract.new();
  });

  it("should add addresses to the whitelist", async () => {
    const address1 = accounts[1];
    const address2 = accounts[2];

    await contractInstance.addToWhitelist(address1);
    await contractInstance.addToWhitelist(address2);

    const isAddress1Whitelisted = await contractInstance.whitelisted(address1);
    const isAddress2Whitelisted = await contractInstance.whitelisted(address2);

    assert.equal(
      isAddress1Whitelisted,
      true,
      "Address 1 should be whitelisted"
    );
    assert.equal(
      isAddress2Whitelisted,
      true,
      "Address 2 should be whitelisted"
    );
  });

  it("should mint NFTs for whitelisted addresses", async () => {
    const tokenId1 = 1;
    const tokenId2 = 2;

    await contractInstance.addToWhitelist(accounts[1]);
    await contractInstance.addToWhitelist(accounts[2]);
    await contractInstance.startNextPhase();

    await contractInstance.mintNFT(tokenId1, { from: accounts[1] });
    await contractInstance.mintNFT(tokenId2, { from: accounts[2] });

    const owner1 = await contractInstance.ownerOf(tokenId1);
    const owner2 = await contractInstance.ownerOf(tokenId2);

    assert.equal(owner1, accounts[1], "Token 1 should be owned by Address 1");
    assert.equal(owner2, accounts[2], "Token 2 should be owned by Address 2");
  });

  it("should prevent non-whitelisted addresses from minting NFTs", async () => {
    const tokenId = 1;

    await contractInstance.addToWhitelist(accounts[1]);
    await contractInstance.startNextPhase();

    try {
      await contractInstance.mintNFT(tokenId, { from: accounts[2] });
      assert.fail("Expected an exception to be thrown");
    } catch (error) {
      assert.include(
        error.message,
        "Address not whitelisted",
        "Should revert on non-whitelisted address"
      );
    }
  });

  it("should prevent addresses from minting multiple NFTs", async () => {
    const tokenId = 1;

    await contractInstance.addToWhitelist(accounts[1]);
    await contractInstance.startNextPhase();

    await contractInstance.mintNFT(tokenId, { from: accounts[1] });

    try {
      await contractInstance.mintNFT(tokenId, { from: accounts[1] });
      assert.fail("Expected an exception to be thrown");
    } catch (error) {
      assert.include(
        error.message,
        "Address has already minted an NFT",
        "Should revert on multiple minting attempts"
      );
    }
  });
});
