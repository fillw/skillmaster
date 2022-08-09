// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract SToken is ERC20, ERC20Burnable, Ownable {

    uint256 constant public max_supply = 10000000 ether;

    constructor() ERC20("STOKEN", "STOKEN")
    {
    }

    function mint(address to, uint256 amount) public onlyOwner
    {
        require(totalSupply() + amount <= max_supply, "max_supply limit");
        _mint(to, amount);
    }
}