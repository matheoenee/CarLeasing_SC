// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

    import "./CarNFT.sol";
    import "@openzeppelin/contracts/utils/Counters.sol";

    contract Lease {
        //uint private lease_id;
        address payable tenant; // this needs to be the nft owner (and contract owner)
        address payable owner;
        address payable seller;
        
        using Counters for Counters.Counter;

        Counters.Counter private _tenant_id_counter;

        // Each car is a struct, and will be implemented as an NFT
        struct Car {
            string licence_num;
            uint256 nft_id;
            string model;
            string color;
            uint retail_value;
            uint matriculation_year;
            address payable owner;
            address payable current_tenant;
        }
        
        // Create a mapping of all the cars, licence_num => Car
        mapping(string => Car) public cars;

        // Struct of users??
        struct Tenant {
            uint tenant_id;
            address payable tenant_address;
        }

        // Mapping of users, uid => User
        mapping(uint => Tenant) private tenants;

        struct LeasingContract{
            uint license_num;
            uint contract_id;
            uint monthly_payment;
            uint debt;
            uint down_payment;
            uint timestamp;
            address payable tenant_address;
            address payable owner_address;
            address payable seller_address;
        }
    
        mapping(uint => LeasingContract) public LeasingContract_by_No;

        struct LeasingPayment{
            uint payment_id;
            uint license_num;
            uint contract_id;
            uint monthly_payment;
            uint timestamp;
            address payable tenant_address;
            address payable owner_address;
        }
    
        mapping(uint => LeasingPayment) public LeasingPayment_by_No;

        //map nft-id to nft link
        mapping(uint => string) private nfts;

        //map of requested cars, uid => licence_num
        mapping(string => address) private requested_cars;

        // A function to add a car to the cars mapping
        // an ipfs-url will also be linked to nft-id
        // this requires the nft to be minted first (safeMint function call)
        function addCar (
            string memory _license_num,
            string memory _model,
            string memory _color,
            uint _matriculation_year,
            uint _retail_value,
            string memory _ipfs_link,
            address payable _nft_owner,
            address payable _current_tenant
        ) public onlyEmployee {
            CarNFT carNFT = new CarNFT();
            uint256 _nft_id = carNFT.safeMint(_nft_owner, _ipfs_link);
            cars[_license_num] = Car(_license_num, _nft_id, _model, _color, _retail_value, _matriculation_year, _nft_owner, _current_tenant); 
            nfts[_nft_id] = _ipfs_link;
        }

        //Function for adding tenants
        function addTenant (
            address payable _tenant_address
        ) public onlyEmployee {
            uint256 _tenant_id = _tenant_id_counter.current();
            _tenant_id_counter.increment();
            tenants[_tenant_id] = Tenant(_tenant_id, _tenant_address);
        }

        // Return a car based on license number
        function getCar(string memory _licence_num) external view returns (Car memory) {
            return cars[_licence_num];
        }
        
        function getNFT(uint _nft_id) external view returns (string memory) {
            return nfts[_nft_id];
        }

        function requestCar(string memory _license_num) public onlyBuyer condition(requested_cars[_license_num] == address(0)){
            requested_cars[_license_num] = msg.sender;
        }

        //lease a specific car to a specific user
        function leaseCarToUser (
            string memory _license_num, 
            uint _tenant_id
            ) condition(cars[_license_num].current_tenant == address(0)) public onlyEmployee{
            cars[_license_num].current_tenant = tenants[_tenant_id].tenant_address;
        }

        /* We build an enum State which consists of 3 possible values for the state of the contract . 
        Every state variable has a default value of the first member ,‘ State .created ‘ State public state ; */

        constructor() {
            owner = payable(msg.sender);
        }

        modifier condition(bool _condition) {
            require(_condition);
            _;
        }
        // Define a modifier for a function that only the buyer can call
        modifier onlyBuyer() {
            require (msg.sender == tenant, "Only customer can call this.");
            _;
        }
        // Define a modifier for a function that only the seller can call
        modifier onlyEmployee() {
            require (msg.sender == seller, "Only BilBoyd employee can call this.");
            _;
        }
    
    //event Aborted();
    //event PurchaseConfirmed();
    //event ItemReceived();

    /* Define a function to abort the purchase and reclaim the ether .
    This function can only be called by the seller before the
    contract is locked .*/
    //function abort() public onlyEmployee inState(State.Created) {
    //    emit Aborted();
    //    state = State.Inactive;
    //    seller.transfer(address(this).balance);
    //}

    /* Define a function that allows the buyer to confirm the
    purchase .
    52 Transaction has to include ‘2 * value ‘ ether .
    53 The amount of ether will be locked until the function
    confirmReceived is called .*/
    //function confirmPurchase() public inState(State.Created) payable {
    //    emit PurchaseConfirmed();
    //    customer = msg.sender;
    //    state = State.Locked;
    //}

    /* Define a function that allows the buyer to confirm that he
    received the item.
    This will release the locked amount of ether . */
    //function confirmReceived() public onlyEmployee inState(State.Locked) {
    //    emit ItemReceived();
        /* It is essential to change the state first because otherwise ,
        the contracts called using ‘send ‘ below can call in again here.*/
    //    state = State.Inactive ;
        /* NOTE: This actually allows both the buyer and the seller to
        block the refund - the withdraw pattern should be used. */
    //    customer.transfer(value);
    //    employee.transfer(address(this).balance);
    //}
    
}