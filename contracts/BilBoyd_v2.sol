// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

    //import nft-contract and openzeppelin counters
    import "./CarNFT.sol";
    import "@openzeppelin/contracts/utils/Counters.sol";
    import "@openzeppelin/contracts/access/AccessControl.sol";

    contract BilBoyd {
        bytes32 public constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");
        bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
        bytes32 public constant SELLER_ROLE = keccak256("EMPLOYEE_ROLE");
        bytes32 public constant CUSTOMER_ROLE = keccak256("CUSTOMER_ROLE");

        //address payable employyee;
        //address payable customer;
        address payable owner; // owner of company (or admin)
        
        using Counters for Counters.Counter; // for ids that can increment on function call

        Counters.Counter private _customer_id_counter; // tenant id for each added user

        Counters.Counter private _agreement_id_counter; // id for each new contract

        Counters.Counter private _payment_id_counter; // id for each new payment
        
        Counters.Counter private _proposition_id_counter; // id for each new payment

        uint256[6] public durations = [24, 36, 48, 54, 64, 72]; // Lease duration from 2 to 5 years
        uint256[5] public mileageCaps = [10000, 12000, 15000, 18000, 20000]; // Mileage caps per year
    
        uint256 LIFE_MILEAGE = 200000;

        // Each car is a struct, and will be implemented as an NFT
        struct Car {
            string license_num;
            string model;
            string color;
            uint256 matriculation_year;
            uint256 retail_value;
            uint256 nft_id;
            address payable nft_owner;
            uint256 current_tenant_id;
            bool available;
        }
        
        // Create a mapping of all the cars, license_num => Car
        mapping(string => Car) public cars;

        // Struct of users
        struct Customer {
            uint256 customer_id;
            address payable tenant_address;
            uint256 driver_experience;
        }

        // Mapping of users, uid => Tenant
        mapping(uint => Customer) private customers;

        //struct for leases
        struct LeasingContract{
            string license_num;
            uint256 contract_id;
            uint256 customer_id;
            uint256 monthly_quota;
            uint256 deposit;
            uint256 contract_start_date;
            uint256 contract_end_date;
            uint256 next_rent_date;
            uint256 lease_duration_index;
            address payable employee_address; //employee
            string contract_status; // termiate, buy, cancel (only company), active
        }

        //mapping for leasing contracts, contract-id => Contract
        mapping(uint256 => LeasingContract) public leasing_contracts;

        struct LeasingProposition {
            uint256 proposition_id;
            string license_num;
            uint256 duration_index;
            uint256 customer_id;
            uint256 mileage_cap_index;
        }

        mapping(uint256 => LeasingProposition) leasing_propositions;

        //map nft-id to nft link, id => ipfs-link
        mapping(uint256 => string) private nfts;
        
        //----------------------------------ADMIN----------------------------------------

        /*
            Documentation here
        */
        function addEmployee(address payable _employee_address) public onlyRole(DEFAULT_ADMIN_ROLE) {
            
        }

        /*
            Documentation here
        */
        function deleteEmployee(uint256 _employee_id) public onlyRole(DEFAULT_ADMIN_ROLE) {

        }

        //----------------------------------SELLER----------------------------------------


        /*
            Documentation here
        */
        function addCustomer(address payable _customer_address, uint256 _driver_exp) public onlyRole(SELLER_ROLE) {

        }

        /*
            Documentation here
        */
        function deleteCustomer(uint256 _customer_id) public onlyRole(SELLER_ROLE) {

        }

        /*
            Documentation here
            JAN
        */
        function createCar() public onlyRole(SELLER_ROLE) {

        }

        /*
            Documentation here
            JAN
        */
        function removeCar() public onlyRole(SELLER_ROLE) {

        }

        /*
            Documentation here
        */
        function acceptLeasingProposition() public onlyRole(SELLER_ROLE) {

        }

        /*
            Documentation here
        */
        function rejectLeasingProposition() public onlyRole(SELLER_ROLE) {

        }

        /*
            Documentation here
        */
        function cancelAgreement() public onlyRole(SELLER_ROLE) {

        }

        /*
            Documentation here
            JARA
        */
        function setCarMileage() public onlyRole(SELLER_ROLE) {

        }

        //----------------------------------CUSTOMER----------------------------------------

        /*
            Documentation here
        */
        function makeLeaseProposition() public onlyRole(CUSTOMER_ROLE) {

        }

        /*
            Documentation here
        */
        function cancelLeaseProposition() public onlyRole(CUSTOMER_ROLE) {

        }

        /*
            Documentation here
        */
        function payRent() public onlyRole(CUSTOMER_ROLE) {

        }

        /*
            Documentation here
            ELENA
        */
        function terminateLease() public onlyRole(CUSTOMER_ROLE) {

        }

        /*
            Documentation here
            ELENA
        */
        function makeCarPurchaseProposition() public onlyRole(CUSTOMER_ROLE) {

        }

        /*
            Documentation here
            ELENA
        */
        function extendLease() public onlyRole(CUSTOMER_ROLE) {

        }

        //----------------------------------MODIFIERS AND HELPERS----------------------------------------

        /*
        MATHEO
        */
        function calculateMonthlyquota() private {

        }
}