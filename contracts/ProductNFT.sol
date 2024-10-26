

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProductNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    
    

    constructor(address initialOwner)
        ERC721("HamroTea", "HT")
        Ownable(initialOwner)
    {}

    event OwnershipRenounced(address indexed previousOwner, address indexed newOwner);
    event SetApprovalForAll(address indexed operator, bool approved);

    function safeMint(address to, uint256 tokenId,string memory uri)
        public
    {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }


    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // function renounceOwnership() public override onlyOwner {
    //     require(newOwner != address(0), "New owner must be set before renouncing ownership");
    //     emit OwnershipRenounced(owner(), newOwner);
    //     _transferOwnership(newOwner);
    // }
    
    function changeOwnerShip(address newOwnerContract) public {
        _transferOwnership(newOwnerContract);
        emit OwnershipRenounced(owner(), newOwnerContract);
    }

    function setApprovalForAll(address operator, bool approved) public override(ERC721, IERC721) {
        super._setApprovalForAll(msg.sender,operator, approved);
        emit SetApprovalForAll(operator, approved);
    }

    function getContractAddress() public view returns(address){
        return address(this);
    }

    function transfer(address to, uint256 tokenId) public {
        _transfer(owner(), to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}