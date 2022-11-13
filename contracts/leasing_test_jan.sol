// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

    //import nft-contract and openzeppelin counters
    import "./CarNFT.sol";
    import "@openzeppelin/contracts/utils/Counters.sol";

    contract Lease {
        //uint private lease_id;
        address payable tenant; // person leasing a car
        address payable owner; // owner of company (or admin)
        address payable seller;  // person leasing out the car
        
        using Counters for Counters.Counter; // for ids that can increment on function call

        Counters.Counter private _tenant_id_counter; // tenant id for each added user

        Counters.Counter private _leasing_contract_id; // id for each new contract

        Counters.Counter private _lease_payment_id; // id for each new payment

        uint durations[4] = [12, 23, 36, 48];

        // Each car is a struct, and will be implemented as an NFT
        struct Car {
            string license_num;
            uint256 nft_id;
            string model;
            string color;
            uint retail_value;
            uint matriculation_year;
            address payable owner;
            uint256 current_tenant_id;
        }
        
        // Create a mapping of all the cars, license_num => Car
        mapping(string => Car) public cars;

        // Struct of users
        struct Tenant {
            uint tenant_id;
            address payable tenant_address;
            uint driver_experience; //number from 1 to ..?
        }

        // Mapping of users, uid => User
        mapping(uint => Tenant) private tenants;

        //struct for leases
        struct LeasingContract{
            uint license_num;
            uint256 contract_id;
            uint monthly_payment;
            uint debt;
            uint down_payment;
            uint256 timestamp; //lease start
            uint256 current_tenant_id;
            uint lease_duration_index;
            address payable owner_address;
            address payable seller_address;
        }

        //mapping for leasing contracts, contract-id => Contract
        mapping(uint => LeasingContract) public leasing_contracts;

        // struct for payments
        struct LeasingPayment{
            uint256 payment_id;
            uint256 contract_id;
            uint timestamp;
            uint256 paying_tenant_id;
        }

        //mapping for payments, payment-id => Payment
        mapping(uint => LeasingPayment) public leasing_payments;

        //map nft-id to nft link, id => ipfs-link
        mapping(uint256 => string) private nfts;

        //map of requested cars, uid => license_num
        mapping(string => address) private requested_cars;

        // A function to add a car to the cars mapping
        // an ipfs-url will also be linked to nft-id
        // this requires the nft to be minted first (safeMint function call)
        // Caveat: json-structure of car not connected to car-structure (double data entry)
        function addCar (
            string memory _license_num,
            string memory _model,
            string memory _color,
            uint _matriculation_year,
            uint _retail_value,
            string memory _ipfs_link,
            address payable _nft_owner,
            uint256 _current_tenant_id
        ) public onlyEmployee {
            CarNFT carNFT = new CarNFT();
            uint256 _nft_id = carNFT.safeMint(_nft_owner, _ipfs_link);
            cars[_license_num] = Car(_license_num, _nft_id, _model, _color, _retail_value, _matriculation_year, _nft_owner, _current_tenant_id); 
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
        function getCar(string memory _license_num) external view returns (Car memory) {
            return cars[_license_num];
        }

        // Return a car based on nft-id
        function getNFT(uint256 _nft_id) external view returns (string memory) {
            return nfts[_nft_id];
        }

        // Tenant requests a car, and registers as requested if not taken
        function requestCar(string memory _license_num) public onlyBuyer condition(requested_cars[_license_num] == address(0)){
            requested_cars[_license_num] = msg.sender;
        }

        /*
        struct LeasingContract{
            uint license_num;
            uint contract_id;
            uint monthly_payment;
            uint debt;
            uint down_payment;
            uint timestamp;
            uint current_tenant;
            address payable owner_address;
            address payable seller_address;
        }
        */

        //lease a specific car to a specific user
        function leaseCarToUser (
            uint256 _tenant_id,
            string memory _license_num, 
            uint _monthly_payment;
            // uint _debt; // initialize to zero
            uint _down_payment;
            uint _current_tenant;
            // address payable _owner_address; //use from contract
            // address payable _seller_address; // use from contract
            ) condition(cars[_license_num].current_tenant == address(0)) public isSeller{

            uint256 _contract_id = _leasing_contract_id.current();
            _lease_id.increment();

            _timestamp = getTimeNow();

            cars[_license_num].current_tenant = tenants[_tenant_id].tenant_address;
            requested_cars[_license_num] = address(0);
            leasing_contracts[_contract_id] = LeasingContract(_license_num, _contract_id, _monthly_payment, 0, _down_payment, _timestamp, _current_tenant, owner, seller)
        }

        /*
        struct LeasingPayment{
            uint256 payment_id;
            uint256 contract_id;
            uint timestamp;
            uint paying_tenant_id;
        }
        */

        // function for making a payment
        function makePayment (
            uint256 _contract_id,
            uint _timestamp,
            uint256 _paying_tenant_id,
        )isEnoughEther(_contract_id) public {
            uint256 _new_payment_id = _lease_payment_id.current();
            _new_payment_id.increment();

            uint256 _tenant_id = leases[_contract_id].current_tenant_id;
            require(msg.sender != tenants[_tenant_id].tenant_address);
            
            address payable _owner = leases[_contract_id].owner;
            
            uint _amount_to_pay = contracts[_contract_id].monthly_payment;
        
            _owner.transfer(_amount_to_pay);
        
            cars[_paying_tenant_id].current_tenant = _paying_tenant_id;
            payments[_new_payment_id] = LeasingPayment(_new_payment_id, _contract_id, now, _paying_tenant_id);
        }
        
        // Maybe sellCar-function instead?
        function buyCar(
            uint256 _contract_id;
        )isCarTenant isLeaseEndTime public{
            uint 256 _buyer = leases[_contract_id].current_tenant_id;
            _license_num = leases[_contract_id].license_num;
            Car car = cars[_license_num];
            car.owner = payable(msg.sender);
            car.current_tenant_id = 0; //by incrementing the first time a tenant is registered, no tenant has id 0

            CarNFT carNFT = new CarNFT();
            carNFT.transferTokenTo(car.owner, _buyer, car.nft_id); //TODO: cchange this so seller has control
        }

        constructor() {
            owner = payable(msg.sender);
        }

        //Helpers

        // generic condition
        modifier condition(bool _condition) {
            require(_condition);
            _;
        }

        //check if owner (i don't understand)
        modifier isCarOwner(string memory _license_num) {
            require(payable(msg.sender) == cars[_license_num].owner, "Only owner can access this");
            _;
        }
        //check if seller
        modifier isSeller(uint _tenant_id) {
            require (payable(msg.sender) == seller, "Only BilBoyd employee can call this.");
            _;
        }
        //check if tenant
        modifier isCarTenant(uint _license_num) {
            require(payable(msg.sender) == cars[_license_num].current_tenant, "Only tenant can access this");
            _;
        }
        //check if it is time to pay
        modifier isThreeMonthsFromLastPayment(string memory _license_num) {
                uint time = cars[_license_num].timestamp + 90 days;
                require(now >= time, "Less than 3 months from the last payment");
                _;
        }
        //check if it is 3 months from the last time payment
        modifier isPaymentTime(uint _index) {
                uint time = cars[_index].timestamp + 30 days;
                require(now >= time, "Time left to pay leasing");
                _;
        }
        //check if tenant has enough money to pay for what?
        modifier isEnoughEther(uint _contract_id) {
            require(msg.value >= uint(leases[_contract_id].monthly_payment), "Not enough Ether in the wallet");
            _;
        }

        // problem when months have 30, 31, 29 or 28 days...
        // solution: only deal in 30-day periods, and let the date gradually drift?
        modifier isLeaseEndTime(uint256 _contract_id){
            require((now - leases[_contract_id].timestamp) / 60 / 60 / 24 / 30 == durations[leases[_contract_id].lease_duration_index])
        }

        function getTimeNow() returns (uint256){
            return now;
        }
    
}