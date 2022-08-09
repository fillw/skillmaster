// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface INFT {
    event UpdateState(uint256 indexed tokenId, bool indexed newState);
    event SetErc20Address(address indexed oldAddress, address indexed newAddress);
    event SetPlatfromAddress(address  sender,address indexed oldAddress, address indexed newAddress);
    event MintPayable(address indexed userAddress, uint256 indexed amount, address indexed platfromAddress);
    event Withdraw(address indexed to, uint256 indexed amount);
    event eventMultiSafeTransferFrom(address indexed from_addr, address indexed to, uint256[] tokenIds);
    event eventMultiMint(address _to, uint256[] _nftIds, uint256[] tokenIds);
    event eventMultiNftDeposit(address indexed from_addr, address indexed to, uint256[] tokenIds);

    function safeMintEth() external payable;
    function mint(address _to,uint256 _nftId) external;
    function multiMint(address _to, uint256[] memory _nftIds) external;
    function multiSafeTransferFrom(address from, address to, uint256[] memory tokenIds) external;
    function getAllTokensByOwner(address account) external view returns (uint256[] memory);
    function multiNftDeposit(address from, address to, uint256[] memory tokenIds) external;
}