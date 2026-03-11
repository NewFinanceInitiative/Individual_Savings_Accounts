// SPDX-License-Identifier: GPL-3.0

// UMI Platform

// 01001110 01100101 01110111 01000110 01101001
// 01101110 01100001 01101110 01100011 01100101
// 01001001 01101110 01101001 01110100 01101001
// 01100001 01110100 01101001 01110110 01100101 

import"./Interface_ISA.sol";
import"./SafeMaths.sol";

pragma solidity ^0.8.0; 

contract ISA_EtherBasedOnly_SetTime_SetDeposit {
    
    // Library Declaration
    using SafeMath for uint256;
    
    // Public State Variables
    uint256 public MIN_DEPOSIT = 0.001 ether; // 0.001 ether MIN deposit that can be made
    uint256 public MAX_DEPOSIT = 0.1 ether; // 0.1 ether MAX deposit that can be made
    uint256 public MIN_TIME_LIMIT = 31556926; // 1 year MIN contract lifecycle
    uint256 public MAX_TIME_LIMIT = 31556926 * 10; // 10 year MAX contract lifecycle
    
    // Private State Variables
    uint256 private _balance; 
    uint256 private _start_date;
    uint256 private _time_limit;

    address private _owner;
    
    // Events
    event DepositOfETH(address _from, uint256 _amount);
    event WithdrawalOfETH(address _too, uint256 _amount);
    
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
     * - `_time_limit` greater than or equal to `_time_limit` plus `time.blockstamp`.
     * - the transaction can be executed after `block.timestamp` is more than now plus `_time_limit`.
     */
    modifier LockingPeriodOver() {
        if (block.timestamp >= _time_limit + block.timestamp) {
            revert();
        }
        _;
    }
    
    // Constructor
    constructor () payable {
        require (msg.value != 0);
        require (_time_limit != 0 && 
                 _time_limit >= MIN_TIME_LIMIT && 
                 _time_limit <= MAX_TIME_LIMIT);
        _start_date == block.timestamp;
        _owner = msg.sender;
        _balance = _balance.add(msg.value);
        
        emit DepositOfETH(msg.sender, msg.value);
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
     * - `MIN_DEPOSIT` must be more than or equal to `msg.value`
     * - `MAX_DEPOSIT` must be be less than or euqal to `msg.value`.
     * - the transaction transfers ethers from senders wallet to contract `_balance`.
     *
     */
    function DepositEther() public payable {
        require (msg.value >= MIN_DEPOSIT &&
                 msg.value <= MAX_DEPOSIT);
        _balance = _balance.add(msg.value);
        emit DepositOfETH(msg.sender, msg.value);
    }
    
    /**
     * @dev Withdraw ether
     *
     * Requirements:
     *
     * - `amount` must be more than zero to be withdrawn.
     * - the transaction transfers ethers from the contract's `_balance` to the `_owner` address.
     *.  
     */
    function WithdrawETH(uint256 _amount) public OnlyOwner() LockingPeriodOver() {
        require (_amount > 0);
        payable(_owner).transfer(_amount);
        _balance = _balance.sub(_amount); 
        emit WithdrawalOfETH(_owner, _amount);
    }

}