// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import "./ProductNFT.sol";
import "./FractionalToken.sol";
import "./Products.sol";
import "./Participants.sol";

contract SupplyChain {
    enum STAGE {
        ProgressNull,
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

    struct TransactionStruct {
        uint256 id;
        uint256 productId;
        address owner;
        address RMS;
        address MAN;
        address DIS;
        address RET;
        uint256 salePrice;
        string title;
        string description;
        uint256 quantity;
    
        STAGE stage;
        uint256 timestamp;
    }
    

    FractionalToken public erc20Token;
    ProductNFT public erc721Token;
    // Products public products;
    Participants public participants;

    address public registrar;
    // uint public productCount = 0;
    uint public totalTx = 0;
   

    
    TransactionStruct[] transactions;
    mapping(uint256 => TransactionStruct[]) private supplyChainTransaction;
    

    // event CreateProduct(string product_title, uint product_Id);
    event CreateRawMat(string rM_Title, uint rM_Id);
    event BuyProduct(uint product_Id, address buyer);
    event UpdateProductPrice(uint product_Id, uint newPrice);
    event Listed(uint256 indexed listingId, uint256 indexed tokenId, address seller, uint256 price);
    event Sold(uint256 indexed listingId, address buyer);
    
    event ethTransfer(address indexed buyer, address indexed owner, uint256 quantity, uint256 timestamp);

    constructor(address _erc721Token,address _erc20Token, address _registrar, address _participantConAdd) {
        // nftContract = MyToken(_nftContract);
        erc20Token = FractionalToken(_erc20Token);
        erc721Token = ProductNFT(_erc721Token);
        // products = Products(_productsConAddress);
        participants = Participants(_participantConAdd);
        registrar = _registrar;
    }
    


    function RawMaterial(uint256 _productId,string memory _rM_Title, uint _price, string memory _desc, uint _quantity) public  {
        // productCount++;
        totalTx++;
        // products.addRM(address(this),productCount,_rM_Title, _price, _desc, _quantity, url);
        // Products.Product memory product = products.getProduct(productCount, productCount);

        // require(product.stage ==  Products.STAGE.RawMaterialSupply);
        
        // Participants.rawMaterialSupplier memory participant = participants.getRMS();

        address rmsAdd = participants.getRMS();

        transactions.push(
            TransactionStruct(
                totalTx,
                _productId,
                rmsAdd,
                rmsAdd,
                address(0),
                address(0),
                address(0),
                _price,
                _rM_Title,
                _desc,
                _quantity,
              
                STAGE.Init,
                block.timestamp
            ));

        
        TransactionStruct memory newTransaction = TransactionStruct({
        id: totalTx,
        productId: _productId,
        owner: rmsAdd,
        RMS: rmsAdd,
        MAN: address(0),
        DIS: address(0),
        RET: address(0),
        salePrice: _price,
        title: _rM_Title,
        description: _desc,
        quantity: _quantity,
        
        stage: STAGE.Init,
        timestamp: block.timestamp
    });
        

        supplyChainTransaction[totalTx].push(newTransaction);

        // uint256 oldAmount = product.quantity;
        // product.quantity = oldAmount - productAmount;
        
        

    }

    function buyRM(uint256 _productId, string memory _rM_Title, string memory _desc, uint256 _salePrice,uint productAmount) public {// only manifacture
        
        totalTx++;
        
        transactions.push(
            TransactionStruct(
                totalTx,
                _productId,
                participants.getMAN(),
                participants.getRMS(),
                participants.getMAN(),
                address(0),
                address(0),
                _salePrice,
                _rM_Title,
                _desc,
                productAmount,
             
                STAGE.RawMaterialSupply,
                block.timestamp
            ));



        TransactionStruct memory newTransaction = TransactionStruct({
        id: totalTx,
        productId: _productId,
        owner: participants.getMAN(),
        RMS: participants.getRMS(),
        MAN: participants.getMAN(),
        DIS: address(0),
        RET: address(0),
        salePrice: _salePrice,
        title: _rM_Title,
        description: _desc,
        quantity: productAmount,
      
        stage: STAGE.RawMaterialSupply,
        timestamp: block.timestamp
    });
        

        supplyChainTransaction[totalTx].push(newTransaction);

        // uint256 oldAmount = product.quantity;
        // product.quantity = oldAmount - productAmount;
        
        
        // emit BuyProduct(_productId, msg.sender);

    }

    

    function Manufacture(uint256 _productId, string memory _rM_Title, uint _price, string memory _desc, uint _quantity) public {
        

        
        
        totalTx++;

        transactions.push(
            TransactionStruct(
                totalTx,
                _productId,
                participants.getMAN(),
                participants.getRMS(),
                participants.getMAN(),
                address(0),
                address(0),
                _price,
                _rM_Title,
                _desc,
                _quantity,
       
                STAGE.Manufacture,
                block.timestamp
            ));

        TransactionStruct memory newTransaction = TransactionStruct({
        id: totalTx,
        productId: _productId,
        owner: msg.sender,
        RMS: participants.getRMS(),
        MAN: participants.getMAN(),
        DIS: address(0),
        RET: address(0),
        salePrice: _price,
        title: _rM_Title,
        description: _desc,
        quantity: _quantity,
       
        stage: STAGE.Manufacture,
        timestamp: block.timestamp
    });
        

        supplyChainTransaction[totalTx].push(newTransaction);

        // uint256 oldAmount = product.quantity;
        // product.quantity = oldAmount - productAmount;
        
        
        

    }


    
    function Distributor(uint256 _productId, string memory _rM_Title, string memory _desc, uint256 _salePrice, uint productAmount) public  {// only distributor
        

        
        totalTx++;


        transactions.push(
            TransactionStruct(
                totalTx,
                _productId,
                participants.getDIS(),
                participants.getRMS(),
                participants.getMAN(),
                participants.getDIS(),
                address(0),
                _salePrice,
                _rM_Title,
                _desc,
                productAmount,
               
                STAGE.Distribution,
                block.timestamp
            ));


        TransactionStruct memory newTransaction = TransactionStruct({
        id: totalTx,
        productId: _productId,
        owner: participants.getDIS(),
        RMS: participants.getRMS(),
        MAN: participants.getMAN(),
        DIS: participants.getDIS(),
        RET: address(0),
        salePrice: _salePrice,
        title: _rM_Title,
        description: _desc,
        quantity: productAmount,
        
        stage: STAGE.Distribution,
        timestamp: block.timestamp
    });
        

        supplyChainTransaction[totalTx].push(newTransaction);

        // uint256 oldAmount = product.quantity;
        // product.quantity = oldAmount - productAmount;
        
        
        // emit BuyProduct(_productId, msg.sender);

    }

    function Retailor(uint256 _productId, string memory _rM_Title, string memory _desc, uint256 _salePrice, uint productAmount) public {// only distributor
        

       

        

        totalTx++;
        // require(erc20Token.balanceOf(msg.sender) != 0, "You do not own the required fractional tokens");

        transactions.push(
            TransactionStruct(
                totalTx,
                _productId,
                participants.getRET(),
                participants.getRMS(),
                participants.getMAN(),
                participants.getDIS(),
                participants.getRET(),
                _salePrice,
                _rM_Title,
                _desc,
                productAmount,
                
                STAGE.Retail,
                block.timestamp
            ));

        TransactionStruct memory newTransaction = TransactionStruct({
        id: totalTx,
        productId: _productId,
        owner: participants.getRET(),
        RMS: participants.getRMS(),
        MAN: participants.getMAN(),
        DIS: participants.getDIS(),
        RET: participants.getRET(),
        salePrice: _salePrice,
        title: _rM_Title,
        description: _desc,
        quantity: productAmount,
     
        stage: STAGE.Retail,
        timestamp: block.timestamp
    });
        

        supplyChainTransaction[totalTx].push(newTransaction);

        // uint256 oldAmount = product.quantity;
        // product.quantity = oldAmount - productAmount;
        
        
        // emit BuyProduct(_productId, msg.sender);

    }

    function Buyer(address _buyerAdd,uint256 _productId, string memory _rM_Title, string memory _desc, uint256 _salePrice, uint productAmount) public {// only distributor
        

        

        

        totalTx++;
        // require(erc20Token.balanceOf(msg.sender) != 0, "You do not own the required fractional tokens");

        transactions.push(
            TransactionStruct(
                totalTx,
                _productId,
                _buyerAdd,
                participants.getRMS(),
                participants.getMAN(),
                participants.getDIS(),
                participants.getRET(),
                _salePrice,
                _rM_Title,
                _desc,
                productAmount,
               
                STAGE.sold,
                block.timestamp
            ));

        TransactionStruct memory newTransaction = TransactionStruct({
        id: totalTx,
        productId: _productId,
        owner: _buyerAdd,
        RMS: participants.getRMS(),
        MAN: participants.getMAN(),
        DIS: participants.getDIS(),
        RET: participants.getRET(),
        salePrice: _salePrice,
        title: _rM_Title,
        description: _desc,
        quantity: productAmount,
        
        stage: STAGE.sold,
        timestamp: block.timestamp
    });
        

        supplyChainTransaction[totalTx].push(newTransaction);

       

    }



    // function updateProductPrice(uint _productId, uint _newPrice) public onlyRegistrar {
    //     require(_productId > 0 && _productId < productCount, "Invalid product ID");
    //     require(_newPrice > 0, "Price must be above zero");
        
    //     Product storage product = products[_productId - 1];
    //     product.price = _newPrice;

    //     emit UpdateProductPrice(_productId, _newPrice);
    // }


    // function getAllTransactions() public view returns (TransactionStruct[] memory){
    //     return transactions;
    // }

    function getNftOfUsers(uint256 _id) public view returns (TransactionStruct[] memory) {
    return supplyChainTransaction[_id];
    }

    // function getSupplyChainOfProduct(uint256 _productId) public view returns (TransactionStruct[] memory) {
    //     TransactionStruct storage transaction = supplyChainTransaction[_productId][0]; // Access the first struct in the array

    //     require(_productId == transaction.productId, "Idmu");
    // }

    // function getSupplyChainByProductId(uint256 _productId) public view returns (TransactionStruct[] memory SupplyChainOfProduct) {
    // // Access the specific transaction array
    // SupplyChainOfProduct = supplyChainTransaction[_productId];

    // return SupplyChainOfProduct;
    // }

    function getSupplyChainByProductId(uint256 _productId) public view returns (TransactionStruct[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].productId == _productId) {
                count++;
            }
        }

        TransactionStruct[] memory result = new TransactionStruct[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].productId == _productId) {
                result[index] = transactions[i];
                index++;
            }
        }

        return result;
    }


}




