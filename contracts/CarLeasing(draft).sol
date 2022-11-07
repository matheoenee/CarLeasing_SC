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
        uint monthly_payment;
        uint debt;
        uint down_payment;
        uint timestamp;
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
        require(msg.sender == LeasingContract[_index].seller, "Only seller can access this");
        _;
    }
    //check if tenant
    modifier isTenant(uint _index) {
        require(msg.sender != Car_by_No[_index].current_tenant, "Only tenant can access this");
        _;
    }
    //check if it is time to pay
    modifier isThreeMonthsFromLastPayment(uint _index) {
            uint time = Car_by_No[_index].timestamp + 90 days;
            require(now >= time, "Less than 3 months from the last payment");
            _;
    }
    //check if it is 3 months from the last time payment
    modifier isPaymentTime(uint _index) {
            uint time = Car_by_No[_index].timestamp + 30 days;
            require(now >= time, "Time left to pay leasing");
            _;
    }
    //check if tenant has enough money
    modifier isEnoughEther(uint _index) {
        require(msg.value >= uint(Car_by_No[_index].monthly_payment), "Not enough Ether in the wallet");
        _;
    }

//Protection from insolvent customers
    //Detect lack of payments

    //Wait for 3 unpaid months, calculate the debt

    //Get the control over NFT back




     //Modified
    modifier enoughForPayment(uint _index) {
        require(msg.value >= uint(Car_by_No[_index].monthly_payment), "Not enough Ether in the wallet");
        _;
    }
     //Modified
    modifier enoughForDownPayment(uint _index) {
        require(msg.value >= uint(uint(Car_by_No[_index].monthly_payment) + uint(Car_by_No[_index].down_payment)), "Not enough Ether in your wallet");
        _;
    }
     //Modified
    modifier sameTenant(uint _index) {
        require(msg.sender == Car_by_No[_index].current_tenant, "No previous agreement found with you & owner");
        _;
    }

    
    modifier AgreementTimesLeft(uint _index) {
        uint _AgreementNo = Room_by_No[_index].agreementid;
        uint time = RoomAgreement_by_No[_AgreementNo].timestamp + RoomAgreement_by_No[_AgreementNo].lockInPeriod;
        require(now < time, "Agreement already Ended");
        _;
    }
    
    modifier AgreementTimesUp(uint _index) {
        uint _AgreementNo = Room_by_No[_index].agreementid;
        uint time = RoomAgreement_by_No[_AgreementNo].timestamp + RoomAgreement_by_No[_AgreementNo].lockInPeriod;
        require(now > time, "Time is left for contract to end");
        _;
    }

//Seller's functions
    //Accept preposition

    //Reject reposition

//fair exchange (the amount is locked in the SC, and it is unlocked only when BilBoyd signs too).
    function signAgreement(uint _index) public payable notLandLord(_index) enoughAgreementfee(_index) OnlyWhileVacant(_index) {
        //lock money
        //wait until seller signs too
        //if rejected, send money back
        require(msg.sender != address(0));
        address payable _landlord = Room_by_No[_index].landlord;
        uint totalfee = Room_by_No[_index].rent_per_month + Room_by_No[_index].securityDeposit;
        _landlord.transfer(totalfee);
        no_of_agreement++;

        Room_by_No[_index].currentTenant = msg.sender;
        Room_by_No[_index].vacant = false;
        Room_by_No[_index].timestamp = block.timestamp;
        Room_by_No[_index].agreementid = no_of_agreement;
        RoomAgreement_by_No[no_of_agreement]=RoomAgreement(_index,no_of_agreement,Room_by_No[_index].roomname,Room_by_No[_index].roomaddress,Room_by_No[_index].rent_per_month,Room_by_No[_index].securityDeposit,365 days,block.timestamp,msg.sender,_landlord);
        no_of_rent++;
        Rent_by_No[no_of_rent] = Rent(no_of_rent,_index,no_of_agreement,Room_by_No[_index].roomname,Room_by_No[_index].roomaddress,Room_by_No[_index].rent_per_month,now,msg.sender,_landlord);
        
    }


 //Monthly payments   
    function payRent(uint _index) public payable sameTenant(_index) RentTimesUp(_index) enoughRent(_index){
        require(msg.sender != address(0));
        address payable _landlord = Room_by_No[_index].landlord;
        uint _rent = Room_by_No[_index].rent_per_month;
        
        _landlord.transfer(_rent);
        
        Room_by_No[_index].currentTenant = msg.sender;
        Room_by_No[_index].vacant = false;
        no_of_rent++;
        Rent_by_No[no_of_rent] = Rent(no_of_rent,_index,Room_by_No[_index].agreementid,Room_by_No[_index].roomname,Room_by_No[_index].roomaddress,_rent,now,msg.sender,Room_by_No[_index].landlord);
    }

//Helper functions
    //Calculate monthly payment

//Agreement termination options

    //Simply terminate the contract
    function agreementTerminated(uint _index) public onlyOwner(_index) AgreementTimesLeft(_index){
        //terminate the contract
        require(msg.sender != address(0));
        Car_by_No[_index].is_free = true;
    }
    //Extend the lease by one year
    function agreementTerminated(uint _index) public onlyOwner(_index) AgreementTimesLeft(_index){
        //recalculate the monthly payment
        //extend the contract/start a new one
        require(msg.sender != address(0));
        Car_by_No[_index].is_free = true;
    }
    //Buy the car 
    function agreementTerminated(uint _index) public onlyOwner(_index) AgreementTimesLeft(_index){
        //calculate the price
        //wait until payd
        //change nft's owner
        require(msg.sender != address(0));
        Car_by_No[_index].is_free = true;
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
