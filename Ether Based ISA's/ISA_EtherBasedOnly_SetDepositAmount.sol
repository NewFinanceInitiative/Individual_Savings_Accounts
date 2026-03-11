// SPDX-License-Identifier: GPL-3.0

// UMI Platform 

// 01001110 01100101 01110111 01000110 01101001
// 01101110 01100001 01101110 01100011 01100101
// 01001001 01101110 01101001 01110100 01101001
// 01100001 01110100 01101001 01110110 01100101 

import"./Interface_ISA.sol";
import"./SafeMaths.sol";

pragma solidity ^0.8.0; 

contract ISA_EtherBasedOnly_SetDepositAmount {

     // Library Declaration
    using SafeMath for uint256;
    
    // Public State Variables
    uint256 public MIN_DEPOSIT = 0.000001 ether; // MIN_DEPOSIT transaction requirement
    uint256 public MAX_DEPOSIT = 0.25 ether; // 0.25 ether threshold for MAX_DEPOSIT
    
    // Private State Variables
    uint256 private _balance; // Contract balance
    address private _owner; // Contract owner and authorised enabler of modidifier
    
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
    
    // Constructor
    constructor (address _newOwner) payable {
        require (msg.value >= MIN_DEPOSIT);
        require (msg.value <= MAX_DEPOSIT);
        _balance = _balance.add(msg.value);
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
        require (msg.value <= MAX_DEPOSIT);
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
    function WithdrawETH(address _too, uint256 _amount) public OnlyOwner() {
        require (_amount != 0);
        payable(_too).transfer(_amount);
        _balance = _balance.sub(_amount); 
        emit WithdrawalOfETH(_too, _amount);
    }

}