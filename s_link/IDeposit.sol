// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IDeposit {

        // event
    event UpdatePlatfromAddress(address indexed oldAddress, address indexed newAddress);
    event UpdateNtokenAddress(address _oldAddress, address _newAddress);
    event UpdateStokenAddress(address _oldAddress, address _newAddress);
    event StokenDeposit(address indexed userAddress, uint256 indexed amount, address indexed platfromAddress);
    event NtokenDeposit(address indexed userAddress, uint256 indexed amount, address indexed platfromAddres);
    event NftDeposit(address indexed userAddress, uint256 indexed tokenId, address indexed platfromAddres);
    event event_deposit(address indexed from, address indexed target, uint256 value);

    function stokenDeposit(uint256 _amount) external payable;
    function ntokenDeposit(uint256 _amount) external payable;
    function nftDeposit(uint256 _tokenId) external payable;
    function multiNftDeposit(uint256[] memory _tokenIds) external payable;
    function deposit() external   payable;
}