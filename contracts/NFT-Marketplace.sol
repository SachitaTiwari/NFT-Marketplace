// SPDX-License-Identifier: 
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Project is ERC721URIStorage, Ownable, ReentrancyGuard {
    
    uint256 private _tokenIds;
    uint256 private _itemsSold;
    
    uint256 public listingPrice = 0.025 ether;
    
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
        uint256 timestamp;
    }
    
      mapping(uint256 => MarketItem) private idToMarketItem;
    
    event MarketItemCreated(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed owner,
        uint256 price,
        bool sold
    );
    
    event MarketItemSold(
        uint256 indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint256 price
    );
    
    // Fixed constructor with automatic owner assignment
    constructor() 
        ERC721("NFT Marketplace", "NFTM") 
        Ownable(msg.sender) // Automatically sets deployer as owner
    {
        // Contract is ready to use upon deployment
    }
    
    // ================================
    // CORE FUNCTION 1: CREATE AND LIST NFT
    // ================================
    function createToken(string memory tokenURI, uint256 price) 
        public 
        payable 
        returns (uint256) 
    {
        require(msg.value == listingPrice, "Price must be equal to listing price");
        require(price > 0, "Price must be greater than zero");
        require(bytes(tokenURI).length > 0, "Token URI cannot be empty");
        
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        
        return newTokenId;
    }
    
    function createMarketItem(uint256 tokenId, uint256 price) private {
        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false,
            block.timestamp
        );
        
        _transfer(msg.sender, address(this), tokenId);
        
        emit MarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }
    
    // ================================
    // CORE FUNCTION 2: BUY NFT
    // ================================
    function createMarketSale(uint256 tokenId) 
        public 
        payable 
        nonReentrant 
    {
        uint256 price = idToMarketItem[tokenId].price;
        address seller = idToMarketItem[tokenId].seller;
        
        require(msg.value == price, "Please submit the asking price");
        require(!idToMarketItem[tokenId].sold, "Item already sold");
        
        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].sold = true;
        _itemsSold++;
        
        _transfer(address(this), msg.sender, tokenId);
        payable(owner()).transfer(listingPrice);
        payable(seller).transfer(msg.value);
        
        emit MarketItemSold(tokenId, seller, msg.sender, price);
    }
    
    // ================================
    // CORE FUNCTION 3: FETCH MARKET ITEMS
    // ================================
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds;
        uint256 unsoldItemCount = _tokenIds - _itemsSold;
        uint256 currentIndex = 0;
        
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        
        return items;
    }
    
    // ================================
    // UTILITY FUNCTIONS
    // ================================
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }
        
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        
        return items;
    }
    
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;
        
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }
        
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        
        return items;
    }
    
    function updateListingPrice(uint256 _listingPrice) public onlyOwner {
        listingPrice = _listingPrice;
    }
    
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }
    
    function getCurrentTokenId() public view returns (uint256) {
        return _tokenIds;
    }
    
    function getTotalItemsSold() public view returns (uint256) {
        return _itemsSold;
    }
    
    // Emergency withdrawal function for contract owner
    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }
}


















