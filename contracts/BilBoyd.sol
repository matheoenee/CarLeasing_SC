pragma solidity ^0.8.0;

    contract Lease {
        //uint private lease_id;
        address payable public seller;
        address payable public buyer;
        enum State { Created, Locked, Inactive }

        // Each car is a struct, and will be implemented as an NFT
        struct Car {
            uint private licenseNum;
            string model;
            string color;
            uint prodYear;
            uint retailValue;
        }

        // Struct of users??

        struc private User {
            uint uid;
            string username;
            address addr;
        }

        // Create a mapping of all the cars
        mapping(uint => Car) public cars;
        
        // Mapping of users??
        mapping(uint => User) private users;

        // A function to add a car to the cars mapping
        function addCar(
            uint  memory private _licenseNum,
            string memory _model,
            string memory _color,
            uint memory _prodYear,
            uint memory _retailValue
        ) public {
            cars[_licenseNum] = Car(_model, _color, _prodYear, _retailValue); 
        }

        //Function for adding users??
        function addUser(
            uint memory private _uid,
            string memory _username,
            address memory private _addr
        ) private {
            users[_uid] = User(_uid, _username, _addr);
        }


        /* We build an enum State which consists of 3 possible values for the state of the contract . 
        Every state variable has a default value of the first member ,‘ State .created ‘ State public state ; */

        /* We require that the variable " value " in msg is an even number . 
        Division will truncate if it is an odd number .*/
        constructor() public payable {
            seller = msg.sender;
            value = msg.value / 2;
            require ((2 * value) == msg.value, " Value has to be even.");
        }

        modifier condition(bool _condition) {
            require(_condition);
            _;
        }
        // Define a modifier for a function that only the buyer can call
        modifier onlyBuyer() {
            require (msg.sender == buyer, "Only buyer can call this.");
            _;
        }
        // Define a modifier for a function that only the seller can call
        modifier onlySeller() {
            require (msg.sender == seller, "Only seller can call this.");
            _;
        }

        modifier inState(State _state) {
            require (state == _state, " Invalid state.");
            _;
        }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();

    /* Define a function to abort the purchase and reclaim the ether .
    This function can only be called by the seller before the
    contract is locked .*/
    function abort() public onlySeller inState(State.Created) {
        emit Aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

    /* Define a function that allows the buyer to confirm the
    purchase .
    52 Transaction has to include ‘2 * value ‘ ether .
    53 The amount of ether will be locked until the function
    confirmReceived is called .*/
    function confirmPurchase() public inState(State.Created) condition(msg.value == (2 * value)) payable {
        emit PurchaseConfirmed();
        buyer = msg.sender;
        state = State.Locked;
    }

    /* Define a function that allows the buyer to confirm that he
    received the item.
    This will release the locked amount of ether . */
    function confirmReceived() public onlyBuyer inState(State.Locked) {
        emit ItemReceived();
        /* It is essential to change the state first because otherwise ,
        the contracts called using ‘send ‘ below can call in again here.*/
        state = State.Inactive ;
        /* NOTE: This actually allows both the buyer and the seller to
        block the refund - the withdraw pattern should be used. */
        buyer.transfer(value);
        seller.transfer(address(this).balance);
    }
}