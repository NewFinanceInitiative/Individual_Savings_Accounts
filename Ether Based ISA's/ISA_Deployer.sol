// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ISA_EtherBasedOnly_SetTimePeriod.sol";

contract ISAFactory {

    address public owner;

    // Track deployed ISAs
    address[] public deployedISAs;

    mapping(address => address[]) public userISAs;

    event ISACreated(address indexed user, address isaAddress);

    constructor() {
        owner = msg.sender;
    }

    // Create a new ISA for the caller
    function createISA(uint256 _locking_period) payable external {
        ISA_EtherBasedOnly_SetTimePeriod newISA = new ISA_EtherBasedOnly_SetTimePeriod{value: msg.value}(_locking_period, msg.sender);
        deployedISAs.push(address(newISA));
        userISAs[msg.sender].push(address(newISA));

        emit ISACreated(msg.sender, address(newISA));
    }

    // Get all ISAs deployed by a specific user
    function getUserISAs(address user) external view returns (address[] memory) {
        return userISAs[user];
    }

    // Get all deployed ISAs
    function getAllISAs() external view returns (address[] memory) {
        return deployedISAs;
    }
    
}