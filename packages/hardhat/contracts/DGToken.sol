// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract DGToken is ERC20 {
    constructor() ERC20("DGToken", "DGT") {
        _mint(msg.sender, 10000000000 * 10 ** 18);
    }
}