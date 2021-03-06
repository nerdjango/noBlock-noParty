// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Admins.sol";

contract Event is EventAdmins{
    constructor(
        address[] memory _adminList,
        string memory _eventName,
        uint256 _requiredDeposit,
        uint _maxParticipants,
        uint _coolingPeriod
    ){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(EVENT_ADMIN_ROLE, _msgSender());

        if (_adminList.length > 0){
            for(uint i = 0; i < _adminList.length; i++){
                _grantRole(EVENT_ADMIN_ROLE, _adminList[i]);
            }
        }

        if (bytes(_eventName).length != 0){
            eventName = _eventName;
        } else {
            eventName = 'Test';
        }

        if(_requiredDeposit != 0){
            requiredDeposit = _requiredDeposit;
        }else{
            requiredDeposit = 0.02 ether;
        }

        if (_maxParticipants != 0){
            maxParticipants = _maxParticipants;
        }else{
            maxParticipants = 20;
        }

        if (_coolingPeriod != 0) {
            coolingPeriod = _coolingPeriod;
        } else {
            coolingPeriod = 1 weeks;
        }
    }   
    string public eventName;
    uint256 public requiredDeposit;
    uint public maxParticipants;
    uint public registered;
    uint public attended;
    bool public ended;
    bool public cancelled;
    uint public endedAt;
    uint public coolingPeriod;
    uint256 public payoutAmount;

    bytes32 public constant REGISTERED_MEMBER = keccak256("REGISTERED_MEMBER");

    struct Participant {
        string participantName;
        address addr;
        bool attended;
        bool paid;
    }

    mapping (address => Participant) public participants;

    /* Modifiers */
    modifier eventActive {
        require(!ended);
        _;
    }

    modifier noOneRegistered {
        require(registered == 0);
        _;
    }

    modifier eventEnded {
        require(ended);
        _;
    }

    function totalBalance() view public returns (uint256){
        return address(this).balance;
    }

    function isRegistered(address _addr) view public returns (bool){
        return hasRole(REGISTERED_MEMBER, _addr);
    }

    function registerInternal(string memory _participant) internal {
        require(msg.value == requiredDeposit);
        require(registered < maxParticipants);
        require(!isRegistered(msg.sender));

        registered++;
        _grantRole(REGISTERED_MEMBER, msg.sender);
        participants[msg.sender] = Participant(_participant, msg.sender, false, false);
    }

    function register(string memory _participant) external payable eventActive{
        registerInternal(_participant);
    }

    function isAttended(address _addr) view public returns (bool){
        return isRegistered(_addr) && participants[_addr].attended;
    }

    function isPaid(address _addr) view public returns (bool){
        return isRegistered(_addr) && participants[_addr].paid;
    }

    function payout() view public returns(uint256){
        if (attended == 0) return 0;
        return uint(totalBalance()) / uint(attended);
    }

    function endEvent() external onlyOwner eventActive{
        payoutAmount = payout();
        ended = true;
        endedAt = block.timestamp;
    }

    function cancel() external onlyOwner eventActive{
        payoutAmount = requiredDeposit;
        cancelled = true;
        ended = true;
        endedAt = block.timestamp;
    }

    function clear() external onlyOwner eventEnded{
        require(block.timestamp > endedAt + coolingPeriod);
        uint leftOver = totalBalance();
        address owner=owner();
        payable(owner).transfer(leftOver);
    }

    function setMaxParticipants(uint _maxParticipants) external onlyOwner eventActive{
        maxParticipants = _maxParticipants;
    }

    function changeName(string memory _eventName) external onlyOwner noOneRegistered{
        eventName = _eventName;
    }

    function attend(address[] memory _addresses) external onlyAdmin eventActive{
        for( uint i = 0; i < _addresses.length; i++){
            address _addr = _addresses[i];
            require(isRegistered(_addr));
            require(!isAttended(_addr));
            participants[_addr].attended = true;
            attended++;
        }
    }
    function withdraw() external eventEnded{
        require(payoutAmount > 0);
        Participant memory participant = participants[msg.sender];
        require(participant.addr == msg.sender);
        require(cancelled || participant.attended);
        require(participant.paid == false);

        participant.paid = true;
        payable(participant.addr).transfer(payoutAmount);
    }
}