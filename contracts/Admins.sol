// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./OZ/AccessControlEnumerable.sol";
import "./OZ/Destructible.sol";

contract EventAdmins is AccessControlEnumerable, Destructible{
    bytes32 public constant EVENT_ADMIN_ROLE = keccak256("EVENT_ADMIN_ROLE");

    modifier onlyAdmin() {
        require(hasRole(EVENT_ADMIN_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "EventAdmin: must have event admin role to perform operation");
        _;
    }
    function addAdmins(address[] memory addressList) public onlyOwner{
        for(uint i = 0; i < addressList.length; i++){
            _grantRole(EVENT_ADMIN_ROLE, addressList[i]);
        }
    }
    function removeAdmins(address[] memory addressList) public onlyOwner{
        for(uint i = 0; i < addressList.length; i++){
            _revokeRole(EVENT_ADMIN_ROLE, addressList[i]);
        }
    }
    function numOfAdmins() view public returns(uint){
        return getRoleMemberCount(EVENT_ADMIN_ROLE);
    }
    function isAdmin(address _addr) public view returns(bool){
        require(hasRole(EVENT_ADMIN_ROLE, _addr));
        return hasRole(EVENT_ADMIN_ROLE, _addr);
    }

}