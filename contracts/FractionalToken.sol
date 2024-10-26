// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract FractionalToken is ERC20, Ownable, ERC20Permit, ERC721Holder {
    IERC721 public collection;
    uint256 public tokenId;
    bool public initialized = false;
    bool public forSale = false;
    uint256 public salePrice;
    bool public canRedeem = false;
    address public newOwner;

    

    
    constructor(address initialOwner)
        ERC20("FractionalToken", "FT")
        Ownable(initialOwner)
        ERC20Permit("FractionalToken")
    {}

    event OwnershipRenounced(address indexed previousOwner, address indexed newOwner);
    event tokenTransfer(address indexed from, address indexed to, uint256 amount, uint256 time);

    function initialize(address _collection, uint256 _amount,uint _tokenId) external {
        // require(!initialized, "Already initialized");
        require(_amount > 0, "Amount must be bigger than 0");
        collection = IERC721(_collection);
        collection.safeTransferFrom(msg.sender, address(this), _tokenId);
        // initialized = true;
        _mint(msg.sender, _amount);
    }

    function putForSale(uint256 price) external onlyOwner {
        salePrice = price;
        forSale = true;
    }

    function BuyToken(address from,address to, uint amount) external {
        uint256 vendorTokenBalance = balanceOf(from); 
        // require(from != msg.sender, "You can send token to same account");

        require(vendorTokenBalance >= amount, "vendor does not have enough balance");

        _transfer(from, to, amount);
        
    }

    function burn(address account,uint256 amount) public {
        _burn(account, amount);
    }


    function renounceOwnership() public override onlyOwner {
        require(newOwner != address(0), "New owner must be set before renouncing ownership");
        emit OwnershipRenounced(owner(), newOwner);
        _transferOwnership(newOwner);
    }

    function getContractAddress() public view returns (address){
        return address(this);
    }


    function redeem(uint256 _amount) external {
        require(canRedeem, "Redemption not available");
        uint256 totalEther = address(this).balance;
        uint256 toRedeem = _amount * totalEther / totalSupply();

        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(toRedeem);
    }
}
