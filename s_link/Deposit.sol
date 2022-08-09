// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../library/SafeTransfer.sol";
import "./IDeposit.sol";

contract Deposit is Ownable, SafeTransfer, ReentrancyGuard,IDeposit {

    using SafeERC20 for address;

    address public platfromAddress;
    address public stokenAddress;
    address public ntokenAddress;
    address public nftAddress;

    mapping(address => uint256) public _balance;


    constructor(address _platfromAddress, address _stokenAddress, address _ntokenAddress, address _nftAddress)  {
        require(_platfromAddress != address(0) || _stokenAddress != address(0) || _ntokenAddress != address(0) || _nftAddress != address(0), "Is zero address");
        platfromAddress = _platfromAddress;
        stokenAddress = _stokenAddress;
        ntokenAddress = _ntokenAddress;
        nftAddress = _nftAddress;
    }

    // set platfrom address
    function setPlatfromAddress(address _newAddress) public onlyOwner{
        require(_newAddress != address(0), "Is zero address");
        emit UpdatePlatfromAddress(platfromAddress, _newAddress);
        platfromAddress = _newAddress;
    }

    // set ntoken address
    function setNtokenAddress(address _newNtokenAddress) public onlyOwner {
        require(_newNtokenAddress != address(0), "Is zero address");
        emit UpdateNtokenAddress(ntokenAddress, _newNtokenAddress);
        ntokenAddress = _newNtokenAddress;
    }

    // set stoken address
    function setStokenAddress(address _newStokenAddress) public onlyOwner  {
        require(_newStokenAddress != address(0), "Is zero address");
        emit UpdateStokenAddress(stokenAddress, _newStokenAddress);
        stokenAddress = _newStokenAddress;
    }

    function doDeposit(uint256 _tokenId) internal {
        IERC721 oToken = IERC721(nftAddress);
        oToken.safeTransferFrom(msg.sender, platfromAddress, _tokenId,"");
        emit NftDeposit(msg.sender, _tokenId, platfromAddress);
    }
    // deposit stoken
    function nftDeposit(uint256 _tokenId) public override payable nonReentrant{
        doDeposit(_tokenId);
    }

    // multi s-token deposit
    function multiNftDeposit(uint256[] memory _tokenIds) external payable nonReentrant {

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            doDeposit(_tokenIds[i]);
        }
    }

    // deposit stoken
    function stokenDeposit(uint256 _amount) external override payable nonReentrant{
        require(_amount > 0, "The amount of deposits is greater than 0");
        uint256 amount = getPayableAmount(stokenAddress, platfromAddress, _amount);
        emit StokenDeposit(msg.sender, amount, platfromAddress);
    }


    // deposit ntoken
    function ntokenDeposit(uint256 _amount) external override payable nonReentrant{
        require(_amount > 0, "The amount of deposits is greater than 0");
        uint256 amount = getPayableAmount(ntokenAddress, platfromAddress, _amount);
        emit NtokenDeposit(msg.sender, amount, platfromAddress);
    }

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function deposit()  external override  payable {
        require(msg.value != 0, "value error");
        _balance[_msgSender()] = _balance[_msgSender()] + msg.value;
        emit event_deposit(_msgSender(), address(this), msg.value);
    }
}
