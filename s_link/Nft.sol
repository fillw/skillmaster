
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./INFT.sol";
import "../library/SafeTransfer.sol";

contract NFT is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, ERC721Burnable, Ownable, SafeTransfer, ReentrancyGuard, INFT {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    Counters.Counter private _tokenIdCounter;

    // There are four different types
 
    uint256 constant public price = 0.001 ether;
    uint256 constant public soldLimit = 1 gwei;

    address payable public platfromAddress;

    constructor(address payable _platfromAddress) ERC721("NFT", "NFT") {
        require(_platfromAddress != address(0) , "address is not null");

        platfromAddress = _platfromAddress;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setPlatfromAddress(address payable _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Platfrom address is NOT null");
        address _oldPlatfromAddress = platfromAddress;
        platfromAddress = _newAddress;
        emit SetPlatfromAddress(msg.sender,_oldPlatfromAddress, _newAddress);
    }


    function _baseURI() internal override view virtual returns (string memory) {
        return "https://app.tienhaitcl.com/user_nft_api/get_token_id_metadata?nft_id=";
    }

     function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        // delete  index
        require(ownerOf(tokenId) == _msgSender(), "only owner can burn");
        super._burn(tokenId);
    }

    function doMint(address _to,uint256 _nftId) internal returns (uint256) {
        // safeMint
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, Strings.toString(_nftId));
        // set default state

        return tokenId;
    }

    function mint(address _to,uint256 _nftId) public override nonReentrant onlyOwner {
        doMint(_to, _nftId);
    }

    // mint eth type (ntoken)
    function safeMintEth() external override payable nonReentrant {
        // Verify the signature
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId<=soldLimit, "Nft sold out.");
        require(msg.value >= price, "Not enough ether sent.");
        // refund
        if (msg.value - price > 0) {
          (bool success, ) = payable(msg.sender).call{value: msg.value - price}(
            ""
          );
          require(success, "refund Failed to send Ether");
        }
        // payable
        (bool result, ) = payable(platfromAddress).call{value: price}("");
        require(result, "Failed to send Ether");
        // safeMint
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, Strings.toString(tokenId));
        // set default state
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }


    // token url
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _getBalance() internal view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public nonReentrant onlyOwner{
          // withdraw eth
          emit Withdraw(platfromAddress, _getBalance());
          (bool success, ) = payable(platfromAddress).call{value: _getBalance()}(
            ""
          );
          require(success, "Failed to send Ether");
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

      function getAllTokensByOwner(address account) external override view returns (uint256[] memory) {
      uint256 length = balanceOf(account);
      uint256[] memory result = new uint256[](length);
      for (uint i = 0; i < length; i++)
          result[i] = tokenOfOwnerByIndex(account, i);
      return result;
    }

    function multiMint(address _to, uint256[] memory _nftIds) external nonReentrant onlyOwner {

        require(_nftIds.length > 0, "nft id len error");

        uint256[] memory token_id = new uint256[](_nftIds.length);

        for (uint256 i = 0; i < _nftIds.length; i++) {
            uint256 _id = doMint(_to, _nftIds[i]);
            token_id[i] = _id;
        }
        emit eventMultiMint(_to, _nftIds, token_id);
    }

    function multiSafeTransferFrom(address from, address to, uint256[] memory tokenIds) external{

        for (uint256 i = 0; i < tokenIds.length; i++) {
            safeTransferFrom(from, to, tokenIds[i]);
        }

        emit eventMultiSafeTransferFrom(from, to, tokenIds);
    }

    function multiNftDeposit(address from, address to, uint256[] memory tokenIds) external{

        for (uint256 i = 0; i < tokenIds.length; i++) {
            safeTransferFrom(from, to, tokenIds[i]);
        }

        emit eventMultiNftDeposit(from, to, tokenIds);
    }
}
