// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract customToken is ERC20 {
    // Token details
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    // Tax and fee details
    uint256 private _buyTaxPercentage;
    uint256 private _sellTaxPercentage;
    uint256 private _feePercentage;
    address private _feeConversionWallet;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        uint256 buyTaxPercentage_,
        uint256 sellTaxPercentage_,
        uint256 feePercentage_,
        address feeConversionWallet_
    ) ERC20(name_, symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _mint(msg.sender, initialSupply_);

        _buyTaxPercentage = buyTaxPercentage_;
        _sellTaxPercentage = sellTaxPercentage_;
        _feePercentage = feePercentage_;
        _feeConversionWallet = feeConversionWallet_;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 taxPercentage = recipient == address(this)
            ? _sellTaxPercentage
            : _buyTaxPercentage;

        if (taxPercentage > 0) {
            uint256 taxAmount = (amount * taxPercentage) / 100;
            uint256 taxedAmount = amount - taxAmount;

            // Convert tax to ETH and send it to the designated wallet
            if (_feePercentage > 0) {
                uint256 feeAmount = (taxAmount * _feePercentage) / 100;
                uint256 ethAmount = convertToEth(feeAmount);
                (bool success, ) = _feeConversionWallet.call{value: ethAmount}(
                    ""
                );
                require(success, "Fee conversion failed");
            }

            emit Transfer(sender, address(this), taxAmount);
            emit Transfer(sender, recipient, taxedAmount);
        } else {
            emit Transfer(sender, recipient, amount);
        }
        return true;
    }

    function convertToEth(uint256 amount) public view returns (uint256) {
        uint256 ethAmount = (amount * 1 ether) / (10 ** uint256(_decimals));
        return ethAmount;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }
}
