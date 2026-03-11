// SPDX-License-Identifier: GPL-3.0

// UMI Platform 

// 01001110 01100101 01110111 01000110 01101001
// 01101110 01100001 01101110 01100011 01100101
// 01001001 01101110 01101001 01110100 01101001
// 01100001 01110100 01101001 01110110 01100101 

import"./Interface_ISA.sol";
import"./SafeMaths.sol";

pragma solidity ^0.8.0; 

contract ISA_EtherBasedOnly_SetTimePeriod {
    
    // Library Declaration
    using SafeMath for uint256;
    
    // Public State Variables
    uint256 public MIN_DEPOSIT = 0 ether; // ZER0 deposit transaction requirement
    uint256 public MAX_DEPOSIT = 120000000 ether; // 120,000,000 ether
    uint256 public MIN_TIME_LIMIT = 0; // ZERO length time limit
    uint256 public MAX_TIME_LIMIT = 4920989335; // 100 years MAX time limit for contract lifecycle.
    
    // Private State Variables
    uint256 private _balance; // Contract balance
    uint256 private _time_locking_period; // Time length of locking period
    
    address private _owner; // Contract owner and authorised enabler of modidifier
    
    // Events
    event DepositOfETH(address _from, uint256 _amount);
    event WithdrawalOfETH(address _too, uint256 _amount);
    event ChangeOfOwnership(address _newOwner);
    
     /**
     * @dev Modifider for "owner" of the contract.
     *
     * Requirements:
     *
     * - `_owner` must be msg.sender.
     * - the caller must be the `_owner` of the contract.
     */
    modifier OnlyOwner() {
        require (msg.sender == _owner);
        _;
    }
    
     /**
     * @dev Modifier for the "time locking period" of the contract.
     *
     * Requirements:
     *
     * - `_time_locking_period` cannot be less than `time.blockstamp`.
     * - the transaction must be executed after `_time_locking_period` is less than now.
     */
    modifier LockingPeriodOver() {
        if (_time_locking_period >= block.timestamp) {
            revert("The locking period is not over");
        }
        _;
    }
    
    // Constructor
    constructor (uint256 _locking_period, address _newOwner) payable {
        require (_locking_period >  block.timestamp);
        require (msg.value != MIN_DEPOSIT);
        require (_locking_period != MIN_TIME_LIMIT);
        _balance = _balance.add(msg.value);
        _time_locking_period = _locking_period;
        _owner = _newOwner;
    }
    
    /**
     * @dev See Balance
     */
    function GetBalance() public OnlyOwner() view returns (uint256) {
        return _balance;
    }
    
    /**
     * @dev Deposit ether
     *
     * Requirements:
     *
     * - `MIN_DEPOSIT` cannot be less than `msg.value`.
     * - the transaction transfers ethers from senders wallet to contract `_balance`.
     *
     */
    function DepositEther() public payable {
        require (msg.value >= MIN_DEPOSIT);
        _balance = _balance.add(msg.value);
        emit DepositOfETH(msg.sender, msg.value);
    }
    
    /**
     * @dev Withdraw ether
     *
     * Requirements:
     *
     * - `ZERO` cannot be less than or equal to `_amount` being withdrawn.
     * - the transaction transfers ethers from the contract's `_balance` to the `too` address given
     *.  as a parameter.
     */
    function WithdrawETH(address _too, uint256 _amount) public OnlyOwner() LockingPeriodOver() {
        require (_amount != 0);
        payable(_too).transfer(_amount);
        _balance = _balance.sub(_amount); 
        emit WithdrawalOfETH(_too, _amount);
    }
    
    /**
     * @dev Change contract owner
     */
    function ChangeOwner(address _newOwner) public OnlyOwner() {
        _owner = _newOwner;
        emit ChangeOfOwnership(_newOwner);
    }

}