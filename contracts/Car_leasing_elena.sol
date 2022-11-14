pragma solidity ^0.5.16;

contract CarLeasing{
    address payable tenant;
    address payable owner;
    address payable seller;
    
    struct Car{
        uint car_id;
        uint nft_id;
        string model;
        string colour;
        uint original_value;
        uint matriculation_year;
        bool is_free;
        address payable owner;
        address payable current_tenant;
    }
    
    mapping(uint => Car) public Car_by_No;
    
    struct LeasingContract{
        uint car_id;
        uint contract_id;
        uint seller_id;
        uint tenant_id;
        uint monthly_payment;
        uint lease_period;
        uint debt;
        uint down_payment;
        uint timestamp;
        uint termination_timestamp;
        string termination_option;
        bool is_signed_by_seller;
        bool is_active;
        address payable tenantAddress;
        address payable ownerAddress;
        address payable sellerAddress;
    }
    
   mapping(uint => LeasingContract) public LeasingContract_by_No;
    
    struct LeasingPayment{
        uint payment_id;
        uint car_id;
        uint contract_id;
        uint monthly_payment;
        uint timestamp;
        address payable tenantAddress;
        address payable ownerAddress;
    }
    
   mapping(uint => LeasingPayment) public LeasingPayment_by_No;

//Helpers
    //check if owner
    modifier isOwner(uint _index) {
        require(msg.sender == Car_by_No[_index].owner, "Only owner can access this");
        _;
    }
    //cheeck if seller
    modifier isSeller(uint _index) {
        require(msg.sender == LeasingContract[_index].seller_id, "Only seller can access this");
        _;
    }
    //check if tenant
    modifier isTenant(uint _index) {
        require(msg.sender != Car_by_No[_index].current_tenant, "Only tenant can access this");
        _;
    }
    //check if it is 3 months from the last time payment
    modifier isThreeMonthsFromLastPayment(uint _index) {
            uint time = Car_by_No[_index].timestamp + 90 days;
            require(now >= time, "Less than 3 months from the last payment");
            _;
    }
    //check if it is time to pay
    modifier isPaymentTime(uint _index) {
            uint time = Car_by_No[_index].timestamp + 30 days;
            require(now >= time, "Time left to pay leasing");
            _;
    }
    //check if tenant has enough money for monthly payment
    modifier isEnoughEther(uint _index) {
        require(msg.value >= uint(LeasingContract[_index].monthly_payment), "Not enough Ether in the wallet");
        _;
    }
    //checks if car is free
    modifier isCarFree(uint _index) {
            uint is_free = Car_by_No[_index].is_free;
            require(is_free, "Car is not vacant");
            _;
    }
    //checks is debt = down payment
    modifier isDebtLimitReached(uint _index) {
            uint debt = LeasingContract[_index].debt;
            uint down_payment = LeasingContract[_index].down_payment;
            require(debt >= down_payment, "Debt is less than down payment");
            _;
    }
     //check if tenant has enough money for down payment + first monthly payment
    modifier enoughForDownPayment(uint _index) {
        require(msg.value >= uint(uint(LeasingContract[_index].monthly_payment) + uint(LeasingContract[_index].down_payment)), "Not enough Ether in your wallet");
        _;
    }

    //checks tenant
     modifier sameTenant(uint _index) {
        require(msg.sender == Car_by_No[_index].current_tenant, "No agreement found with customer");
        _;
    }
    //checks termination options
    modifier isNormalTerminationOption(uint _index) {
        require(LeasingContract[_index].termination_option == "terminate", "Normal termination is not selected termination option");
        _;
    }
    //checks termination options
    modifier IsExtendingTerminationOption(uint _index) {
        require(LeasingContract[_index].termination_option == "extend", "Extending is not selected termination option");
        _;
    }
    //checks termination options
    modifier isSellingTerminationOption(uint _index) {
        require(LeasingContract[_index].termination_option == "sell", "Selling is not selected termination option");
        _;
    }
    //checks if digned by seller
    modifier isSignedBySeller(uint _index) {
        require(LeasingContract[_index].is_signed_by_seller == true, "Seller did not signed the contract yet");
        _;
    }
//Protection from insolvent customers
    //Detect lack of payments

    //Wait for 3 unpaid months, calculate the debt
    
    //Get the control over NFT back
    function debtAction(uint _index) public payable isSeller(_index) isDebtLimitReached(_index) {

    }

modifier AgreementNotExpired(uint _index) {
        uint time = LeasingContract[_index].timestamp + LeasingContract[_index].lease_period;
        require(now < time, "Agreement is already expired);
        _;
    }
    
    modifier AgreementExpired(uint _index) {
        uint time = LeasingContract[_index].timestamp + LeasingContract[_index].lease_period;
        require(now >= time, "Time is left for contract to end");
        _;
    }

//Seller's functions
    //Accept preposition
    function acceptProposition(uint _index) public payable isSeller(_index) enoughForDownPayment(_index) isCarFree(LeasingContract[_index].car_id) {
        LeasingContract[_index].is_signed_by_seller = true;
        Car_by_No[LeasingContract[_index].car_id].is_free = false;
        LeasingContract[_index].debt = 0;
        LeasingContract[_index].timestamp = now;
    }
    //Reject reposition
    function rejectProposition(uint _index) public payable isSeller(_index) {
    //return ether to customer
    }

//fair exchange (the amount is locked in the SC, and it is unlocked only when BilBoyd signs too).
    function signAgreement(uint _index) public payable notLandLord(_index) enoughAgreementfee(_index) OnlyWhileVacant(_index) {
        //lock money
        //wait until seller signs too
        //if rejected, send money back  
    }

    function completeContractSigning(uint _index) public payable isSignedBySeller(_index) {
        //lock money
        //wait until seller signs too
        //if rejected, send money back

    }


 //Monthly payments   
    function payLeasing(uint _index) public payable sameTenant(_index) isEnoughEther(_index) isPaymentTime(_index){
        require(msg.sender != address(0));
        address payable _owner = Car_by_No[_index].owner;
        uint _payment = LeasingContract[_index].monthly_payment;
        
        _owner.transfer(_payment);

        //Rent_by_No[no_of_rent] = Rent(no_of_rent,_index,Room_by_No[_index].agreementid,Room_by_No[_index].roomname,Room_by_No[_index].roomaddress,_rent,now,msg.sender,Room_by_No[_index].landlord);
    }

//Helper functions
    //Calculate monthly payment

//Agreement termination options

    //Simply terminate the contract
    function terminateContract(uint _index) public isSeller(_index) AgreementExpired(_index) isNormalTerminationOption (_index){
        LeasingContract[_index].is_active = false;
        LeasingContract[_index].termination_timestamp = now;
        Car_by_No[LeasingContract[_index].car_id].is_free = true;
    }
    //Extend the lease by one year
    function extendContractByOneYear(uint _index) public onlyOwner(_index) AgreementExpired(_index) IsExtendingTerminationOption(_index){

        //recalculate the monthly payment
        //extend the contract/start a new one
 
    }
    //Buy the car 
    function terminateContractBySellingCar(uint _index) public onlyOwner(_index) AgreementExpired(_index) isSellingTerminationOption(_index){
        LeasingContract[_index].is_active = false;
        LeasingContract[_index].termination_timestamp = now;
        Car_by_No[LeasingContract[_index].car_id].is_free = true;
        //calculate the price
        //wait until payd
        //change nft's owner

    }
    
    function agreementCompleted(uint _index) public payable onlyLandlord(_index) AgreementTimesUp(_index){
        require(msg.sender != address(0));
        require(Room_by_No[_index].vacant == false, "Room is currently Occupied.");
        Room_by_No[_index].vacant = true;
        address payable _Tenant = Room_by_No[_index].currentTenant;
        uint _securitydeposit = Room_by_No[_index].securityDeposit;
        _Tenant.transfer(_securitydeposit);
    }
    
}
