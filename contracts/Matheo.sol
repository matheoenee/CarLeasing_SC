// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counter.sol";

contract CarLeasing is ERC721, ERC721URIStorage, ERC721Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SELLER_ROLE = keccak256("EMPLOYEE_ROLE");
    bytes32 public constant SELLER_ROLE = keccak256("CUSTOMER_ROLE");

    using Counters for Counters.Counter;
    Counters.Counter private _carIds;
    Counters.Counter private _agreementIds;
    Counters.Counter private _employeeIds;
    Counters.Counter private _customerIds;

    uint256 durations[5] = [24, 36, 48, 54, 64, 72]; // Lease duration from 2 to 5 years
    uint256 mileageCaps[4] = [10000, 12000, 15000, 18000, 20000]; // Mileage caps per year

    // Need to implement function to assure that the mileage cap is respected !!!

    struct Car{
        uint256 carId;
        uint256 agreementId;
        uint256 carMatriculationYear;
        string carModel;
        string carColor;
        uint carValue;
        bool available;
    }

    struct Agreement{ // Create when an employee accept a Proposition
        uint256 agreementId; // Increment counter at creation
        uint256 carId; // (parameter)
        uint256 employeeId; // Set up at msg.sender at creation (Employee address)
        uint256 customerId; // (parameter)
    
        uint256 duration; // Define a set of value (parameter)

        uint256 mileageCap; // Define a set of value (parameter)
        uint256 previousCarMileage; // Car mileage at the beginning of the year
        uint256 carMileage; // Current car mileage (parameter)
        uint256 timeMileageReset; // Set up at now + 1 year at the creation 

        uint256 rent_per_month; // Compute this value at the creation
        uint256 securityDeposit; // (parameter)
        uint256 timeRentDue; // Set up now at the creation
    
        address payable tenant;
        address payable owner;
    }

    struct Proposition{
        uint256 carId;
        uint256 employeeId;
        uint256 customerId;
    }

    // Create dictionnary with available cars and unavailable ??
    mapping(uint256 => Car) public cars;
    mapping(uint256 => Agreement) public agreements;

    constructor() ERC721("CarLeasing", "CL") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }
    /*------------------------------------------------------
                        MODIFIERS
    ------------------------------------------------------*/
    modifier OnlyWhileAvailable(uint _carId){  
        require(Room_by_No[_index].vacant == true, "Room is currently Occupied.");
        _;
    }


    /*------------------------------------------------------
                        OWNER FUNCTIONS
    ------------------------------------------------------*/

    // Give SELLER_ROLE and approval to an address
    function addEmployee(address account)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _grantRole(EMPLOYEE_ROLE, account); // Give the seller role to an address
        setApprovalForAll(account, true); // Give the approval to a seller to transfer owner NFT
    }

    // Add new car
    addCar()
        public
        onlyRole(MINTER_ROLE)
    {
        _carIds.increment();

        uint256 newCarId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
    }

    function safeMint(address to, uint256 tokenId, string memory uri)
        public
        onlyRole(MINTER_ROLE)
    {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

     /*------------------------------------------------------
                        CUSTOMER FUNCTIONS
    ---------------------------------------------------------
    - Make a proposition for a specific car,duration,mileagecap 
    - Delete a proposition
    - Pay the rent and specify the mileage of the car
    - Terminate the contract ==> how ?
    ------------------------------------------------------*/

    function makeProposition(uint256 carId, uint256 durationIndex, uint256 mileageCapIndex){
        // TO DO
    }

    function payRent(uint256 agreementId, uint256 mileage) 
        external 
        payable
        onlyRole(CUSTOMER_ROLE)
        isTenant(agreementId)
        isMileageAcceptable(agreementId, mileage)
        isRentEnough(agreementId)

    {
        // TO DO
    }


    modifier isTenant(uint256 _index) { 
        require(msg.sender == Agreement_by_No[_index].tenant, "Only tenant can access this.");
        _;
    }

    modifier isMileageAcceptable(uint256 _index, uint256 _mileage) { 
        require(mileage >= Agreement_by_No[_index].carMileage, "Car mileage not acceptable, less than previous one.");
        _;
    }

    modifier isRentEnough(uint256 _index) { 
        
        amountOwe = 0;
        require(msg.value == amountOwn, "");
        _;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}