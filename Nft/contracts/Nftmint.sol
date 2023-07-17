// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Nftmint is ERC721, Ownable {
    mapping(address => bool) private whitelist;
    mapping(address => bool) private hasMinted;
    uint private currentPhase = 0;

    constructor() ERC721("MyNFT", "NFT") {}

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Address not whitelisted");
        _;
    }

    modifier canMint() {
        require(currentPhase > 0, "Minting is not allowed yet");
        require(whitelist[msg.sender], "Address not whitelisted");
        require(!hasMinted[msg.sender], "Address has already minted an NFT");
        _;
    }

    function addToWhitelist(address _address) external onlyOwner {
        whitelist[_address] = true;
    }

    function removeFromWhitelist(address _address) external onlyOwner {
        whitelist[_address] = false;
    }

    function startNextPhase() external onlyOwner {
        currentPhase++;
    }

    function mintNFT(uint256 tokenId) external onlyWhitelisted canMint {
        _safeMint(msg.sender, tokenId);
        hasMinted[msg.sender] = true;
    }

    function whitelisted(address _address) external view returns (bool) {
        return whitelist[_address];
    }
}
