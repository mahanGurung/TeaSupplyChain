// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
// import "@openzeppelin/contracts/access/Ownable.sol";


contract Participants {    
    //Raw material supplier count
    uint256 public rmsCount = 0;
    //Manufacturer count
    uint256 public manCount = 0;
    //distributor count
    uint256 public disCount = 0;
    //retailer count
    uint256 public retCount = 0;

    struct rawMaterialSupplier {
        address addr;
        uint256 id; //supplier id
        string name; //Name of the raw material supplier
        string place; //Place the raw material supplier is based in
        
    }

    struct manufacturer {
        address addr;
        uint256 id; //manufacturer id
        string name; //Name of the manufacturer
        string place; //Place the manufacturer is based in
    }

    struct distributor {
        address addr;
        uint256 id; //distributor id
        string name; //Name of the distributor
        string place; //Place the distributor is based in
    }

    struct retailer {
        address addr;
        uint256 id; //retailer id
        string name; //Name of the retailer
        string place; //Place the retailer is based in
    }

    mapping(uint256 => rawMaterialSupplier) public RMS;// use uint to for mapping
    mapping(uint256 => manufacturer) public MAN;// use uint to for mapping
    mapping(uint256 => distributor) public DIS;// use uint to for mapping
    mapping(uint256 => retailer) public RET;// use uint to for mapping

    

     //To add raw material suppliers. Only contract owner can add a new raw material supplier
    function addRMS(
        address _address,
        string memory _name,
        string memory _place
    ) public {
        require(rmsCount < 1, "Only one account can be made");
        rmsCount++;
        RMS[rmsCount] = rawMaterialSupplier(_address, rmsCount, _name, _place);
    }

    //To add manufacturer. Only contract owner can add a new manufacturer
    function addManufacturer(
        address _address,
        string memory _name,
        string memory _place
    ) public {
        require(manCount < 1, "Only one account can be made");
        manCount++;
        MAN[manCount] = manufacturer(_address, manCount, _name, _place);
    }

     //To add distributor. Only contract owner can add a new distributor
    function addDistributor(
        address _address,
        string memory _name,
        string memory _place
    ) public {
        require(disCount < 1, "Only one account can be made");

        disCount++;
        DIS[disCount] = distributor(_address, disCount, _name, _place);
    }

    //To add retailer. Only contract owner can add a new retailer
    function addRetailer(
        address _address,
        string memory _name,
        string memory _place
    ) public {
        require(retCount < 1, "Only one account can be made");
        retCount++;
        RET[retCount] = retailer(_address, retCount, _name, _place);
    }

    function getRMS() public view returns (address addr) {
        require(rmsCount > 0, "Invalid raw material supplier ID");
        return RMS[rmsCount].addr;
    }

    function getMAN() public view returns (address addr) {
        require(rmsCount > 0, "Invalid manufacturer ID");
        
        return MAN[rmsCount].addr;
    }

    function getDIS() public view returns (address addr) {
        require(rmsCount > 0, "Invalid distributer ID");
        return DIS[rmsCount].addr;
    }

    function getRET() public view returns (address addr) {
        require(rmsCount > 0, "Invalid retailor ID");
        return RET[rmsCount].addr;
    }

}