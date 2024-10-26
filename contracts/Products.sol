// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
// import "@openzeppelin/contracts/access/Ownable.sol";
import "./ProductNFT.sol";
import "./FractionalToken.sol";
import "./Participants.sol";
import "./SupplyChainPlace.sol";



contract Products {

    uint public productCount = 0;

    FractionalToken public erc20Token;
    ProductNFT public erc721Token;
    Participants public participants;
    SupplyChain public supplyChain;
    address public registrar;

    event UpdateProductPrice(uint product_Id, uint newPrice);

    constructor(address _participantConAdd,address _erc721Token,address _erc20Token, address _registrar, address _supplyChain) {
        // nftContract = MyToken(_nftContract);
        erc20Token = FractionalToken(_erc20Token);
        erc721Token = ProductNFT(_erc721Token);
        participants = Participants(_participantConAdd);
        supplyChain = SupplyChain(_supplyChain);
        registrar = _registrar;
    }

    modifier onlyRegistrar() {
        require(msg.sender == registrar, "Only the registrar can register products");
        _;
    }

    modifier onlyRMS() {
        require(msg.sender == participants.getRMS(), "Only the raw material supplier can register products");
        _;
    }

    modifier onlyMAN() {
        require(msg.sender == participants.getMAN(), "Only the manufacturer can register products");
        _;
    }

    modifier onlyDIS() {
        require(msg.sender == participants.getDIS(), "Only the distributer can register products");
        _;
    }

    modifier onlyRET() {
        require(msg.sender == participants.getRET(), "Only the retailor can register products");
        _;
    }

    function addRMS(address _address,string memory _name,string memory _place) public onlyRegistrar {
        participants.addRMS(_address, _name, _place);
    }

    function addManufacturer(address _address,string memory _name,string memory _place) public onlyRegistrar {
        participants.addManufacturer(_address, _name, _place);
    }

    function addDistributor(address _address,string memory _name,string memory _place) public onlyRegistrar {
        participants.addDistributor(_address, _name, _place);
    }

    function addRetailer(address _address,string memory _name,string memory _place) public onlyRegistrar {
        participants.addRetailer(_address, _name, _place);
    }

    


    enum STAGE {
        Init,
        RawMaterialSupply,
        Manufacture,
        Distribution,
        Retail,
        sold
    }

    enum CATEGORY {
        RawMaterial,
        Product
    }

    struct Product {
        uint product_Id;
        string product_Title;
        uint price;
        string desc;
        CATEGORY category;
        uint quantity;
        string nftUrl;
        STAGE stage;
        bool sold;
    }

    Product[] public products;

    event ethTransfer(address indexed buyer, address indexed owner, uint256 quantity, uint256 timestamp);
    event CreateRawMaterial(string product_title, uint product_Id);
    event CreateProduct(string product_title, uint product_Id);
    event BuyProduct(uint product_Id, address buyer);





    function getProduct(uint _productId) public view returns (Product memory) {
        require(_productId > 0 && _productId <= productCount, "Invalid product ID");
        return products[_productId - 1];
    }

    function getAllProduct() public view returns (Product[] memory) {
        return products;
    }

    function fetchTransactionsSupplyChainOfProduct(uint256 _productId) public view returns (SupplyChain.TransactionStruct[] memory) {
        return supplyChain.getSupplyChainByProductId(_productId);
    }


    function uploadNft(uint nfttokenId, string memory nftUrl) public {
        erc721Token.safeMint(registrar, nfttokenId,nftUrl);
    }

    function setApprovalForAll() public {
        address erc20TokenAddress = erc20Token.getContractAddress();
        bool approved = true;

        erc721Token.setApprovalForAll(erc20TokenAddress, approved);
    }

    function changeOwnerShipOfNft(address _to,uint tokenId) public {
        require(_to != address(0), "forgot to input address");////////
        erc721Token.transfer(_to, tokenId);
    }

    // function initializeErc20Token(uint tokenId,uint _quantity) public {
    //     address erc721TokenAddress = erc721Token.getContractAddress();
    //     erc20Token.initialize(erc721TokenAddress, _quantity,tokenId);
    // }



    function initialize(address _to,uint tokenId,uint _quantity,string memory nftUrl) public{
        uploadNft(tokenId, nftUrl);
        changeOwnerShipOfNft(_to,tokenId);
        setApprovalForAll();
        
        address erc721TokenAddress = erc721Token.getContractAddress();

        erc20Token.initialize(erc721TokenAddress, _quantity,tokenId);
    }

    function addRM (string memory _rM_Title, uint256 _price, string memory _desc, uint256 _quantity,string memory url) public onlyRMS {///only rms
        require(_price > 0, "Price must be above zero");
        productCount++;
        
        initialize(address(this), productCount,_quantity, url);

        Product memory tempProduct = Product({
            product_Id: productCount,
            product_Title: _rM_Title,
            price: _price,
            desc: _desc,
            category: CATEGORY.RawMaterial,
            quantity: _quantity,
            nftUrl: url,
            
            stage: STAGE.Init,
            sold: false
            
        });
        

        products.push(tempProduct);
        supplyChain.RawMaterial(productCount,_rM_Title, _price, _desc, _quantity);
        emit CreateRawMaterial(_rM_Title, tempProduct.product_Id);

        
        
    }

    function addProduct (string memory _rM_Title, uint256 _price, string memory _desc) public onlyMAN {
        require(_price > 0, "Price must be above zero");
        // productCount++;
        // initialize(address(this),productCount,_quantity, url);
        require(erc20Token.balanceOf(msg.sender) != 0, "You do not own the required fractional tokens");


        // 
        

        // products.push(tempProduct);
        supplyChain.Manufacture(productCount, _rM_Title, _price, _desc, erc20Token.balanceOf(msg.sender));
        emit CreateProduct(_rM_Title, productCount);

        
        
    }

    function tranferEth(address to, uint256 quantity) public  payable {
        require(msg.value >= quantity, "Not enough ether");
        (bool success, ) = payable(to).call{value: quantity}("");
        require(success, "Failed to send Ether");

        emit ethTransfer(msg.sender, to, quantity, block.timestamp);
    }

    function buyTokenFromRM(uint _productId, uint256 itemAmount) public payable onlyMAN {
        require(_productId > 0 && _productId <= productCount, "Invalid product ID");

        Product storage product = products[_productId - 1];

        // Product memory product = products[];
        require(product.sold == false, "Product already sold");

        uint totalProPrice = product.price / product.quantity;
        uint totalPrice = totalProPrice * itemAmount;
        

        // address tokenOwner = owner();
        require(msg.value >= totalPrice, "Not enough ether");

        address rmsAddr = participants.getRMS();

        tranferEth(rmsAddr, totalPrice);


        erc20Token.BuyToken(address(this), msg.sender, itemAmount);   
        uint256 oldAmount = product.quantity;
        product.quantity = oldAmount - itemAmount; 

        if (product.quantity == 0) {
            product.sold = true;
        } 
        

        supplyChain.buyRM(productCount, product.product_Title, product.desc,totalPrice, itemAmount);

        emit BuyProduct(_productId, msg.sender);
    }

    function buyTokenFromMAN(uint _productId, uint256 itemAmount) public payable onlyDIS {
        require(_productId > 0 && _productId <= productCount, "Invalid product ID");
        require(erc20Token.balanceOf(participants.getMAN()) != 0, "You do not own the required fractional tokens");



        Product storage product = products[_productId - 1];

        // Products.Product memory product = products.getProduct(_productId, productCount);
        require(product.sold == false, "Product already sold");

        uint totalProPrice = product.price / product.quantity;
        uint totalPrice = totalProPrice * itemAmount;
        

        // address tokenOwner = owner();
        require(msg.value >= totalPrice, "Not enough ether");


        address manAddr = participants.getMAN();
        tranferEth(manAddr, totalPrice);


        erc20Token.BuyToken(manAddr, msg.sender, itemAmount); 
        uint256 oldAmount = product.quantity;
        product.quantity = oldAmount - itemAmount;
        
        supplyChain.Distributor(productCount, product.product_Title, product.desc, totalPrice, itemAmount);
          
        emit BuyProduct(_productId, msg.sender);
    }


    function buyTokenFromDis(uint _productId, uint256 itemAmount) public payable onlyRET {
        require(_productId > 0 && _productId <= productCount, "Invalid product ID");
        require(erc20Token.balanceOf(participants.getDIS()) != 0, "You do not own the required fractional tokens");
        Product storage product = products[_productId - 1];


        // Products.Product memory product = products.getProduct(_productId, productCount);
        require(product.sold == false, "Product already sold");

        uint totalProPrice = product.price / product.quantity;
        uint totalPrice = totalProPrice * itemAmount;
        

        // address tokenOwner = owner();
        require(msg.value >= totalPrice, "Not enough ether");

        address disAddr = participants.getDIS();
        tranferEth(disAddr, totalPrice);


        erc20Token.BuyToken(disAddr, msg.sender, itemAmount);
        uint256 oldAmount = product.quantity;
        product.quantity = oldAmount - itemAmount;    

        supplyChain.Retailor(productCount, product.product_Title, product.desc, totalPrice, itemAmount);

        emit BuyProduct(_productId, msg.sender);
    }


    function buyTokenFromRet(uint _productId, uint256 itemAmount) public payable {
        require(_productId > 0 && _productId <= productCount, "Invalid product ID");
        require(erc20Token.balanceOf(participants.getRET()) != 0, "You do not own the required fractional tokens");

        Product storage product = products[_productId - 1];


        // Products.Product memory product = products.getProduct(_productId, productCount);
        require(product.sold == false, "Product already sold");

        uint totalProPrice = product.price / product.quantity;
        uint totalPrice = totalProPrice * itemAmount;
        

        // address tokenOwner = owner();
        require(msg.value >= totalPrice, "Not enough ether");

        address disAddr = participants.getDIS();
        tranferEth(disAddr, totalPrice);


        erc20Token.BuyToken(disAddr, msg.sender, itemAmount);
        uint256 oldAmount = product.quantity;
        product.quantity = oldAmount - itemAmount;

        supplyChain.Buyer(msg.sender, productCount, product.product_Title, product.desc, totalPrice, itemAmount);

        emit BuyProduct(_productId, msg.sender);
    }

    // function updateProductPrice(uint _productId, uint _newPrice) public onlyRegistrar {
    //     require(_productId > 0 && _productId < productCount, "Invalid product ID");
    //     require(_newPrice > 0, "Price must be above zero");
        
    //     Product storage product = products[_productId - 1];
    //     product.price = _newPrice;

    //     emit UpdateProductPrice(_productId, _newPrice);
    // }


}