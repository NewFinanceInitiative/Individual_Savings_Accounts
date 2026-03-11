// SPDX-License-Identifier: GPL-3.0

// UMI Platform 

// 01001110 01100101 01110111 01000110 01101001
// 01101110 01100001 01101110 01100011 01100101
// 01001001 01101110 01101001 01110100 01101001
// 01100001 01110100 01101001 01110110 01100101 

import"./Interface_ISA.sol";
import"./SafeMaths.sol";

pragma solidity ^0.8.0; 

contract ISA_EtherBasedOnly_SetTime_DynamicDeposit {

    // Library Declaration
    using SafeMath for uint256;
    
    // Public State Variables
    uint256 public MIN_DEPOSIT = 0.000000000000000000 ether; // Minimum deposit of ether.
    uint256 public MAX_DEPOSIT = 1 ether; // Maximum deposit of ether.
    uint256 public MIN_TIME_LIMIT = 31556926; // 1 year minimum contract length.
    uint256 public MAX_TIME_LIMIT = 31556926 * 10; // Maximum 10 year contract length.
    
    // Private State Variables
    uint256 private _balance; // Contract balance.
    uint256 private _start_date; // Contract start date.
    uint256 private _time_limit; // Contract time limit 

    address private _owner; // Contract owner.
    
    // Events
    event DepositOfETH(address _from, uint256 _amount);
    event WithdrawalOfETH(address _too, uint256 _amount);
    event UpdatedMinimumDeposit(address _owner, uint256 _amount);
    event UpdateMaximumDeposit(address _owner, uint256 _amount);

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
    constructor (uint256 _set_time_limit) payable {
        require (msg.value != 0);
        require (_set_time_limit != 0 && 
                 _set_time_limit >= MIN_TIME_LIMIT && 
                 _set_time_limit <= MAX_TIME_LIMIT);
        _set_time_limit = _time_limit;
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

    /**
     * @dev Change Minimum Deposit amounts in ether
     *
     * Requirements:
     *
     * - `amount` must be more than zero to alter.
     * - the transaction upadtes the deposit amounts.
     *.  
     */
    function ChangeMinDeposit(uint256 _amount) public OnlyOwner() {
        require (_amount != 0);
        MIN_DEPOSIT = _amount;
        emit UpdatedMinimumDeposit(_owner, _amount);
    }
    
    /**
     * @dev Change Max Deposit amounts in ether
     *
     * Requirements:
     *
     * - `amount` must be more than zero to alter.
     * - the transaction upadtes the deposit amounts.
     *.  
     */
    function ChangeMaxDeposit(uint256 _amount) public OnlyOwner() {
        require (_amount != 0);
        MAX_DEPOSIT = _amount;
        emit UpdateMaximumDeposit(_owner, _amount);
    }

}