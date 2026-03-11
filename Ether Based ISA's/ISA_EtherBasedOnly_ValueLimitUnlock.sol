// SPDX-License-Identifier: GPL-3.0

// UMI Platform 

// 01001110 01100101 01110111 01000110 01101001
// 01101110 01100001 01101110 01100011 01100101
// 01001001 01101110 01101001 01110100 01101001
// 01100001 01110100 01101001 01110110 01100101 

import"./Interface_ISA.sol";
import"./SafeMaths.sol";

pragma solidity ^0.8.0; 

contract ISA_EtherBasedOnly_ValueLimitUnlock {

    using SafeMath for uint256;

    uint256 public MIN_DEPO_AMOUNT = 0.000000000000000000 ether;
    uint256 public MAX_DEPO_AMOUNT = 120000000.000000000000000000 ether;
    uint256 public VALUE_LIMIT_UNLOCK_AMOUNT = 0.000000000000000000 ether;

    uint256 private _balance;
    uint256 private _start_date;
    uint256 private _end_date;
    
    address private _owner;

    event DepositOfEther(address _from, uint256 _amount);
    event UnlockAmountAcheived(uint256 _amount, uint256 _end_date);
    event AmountWithdrawn(address _too, uint256 _amount);

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

    modifier UnlockAmountSuccess() {
        require (_balance >= VALUE_LIMIT_UNLOCK_AMOUNT);
        _;
    }

    constructor (uint256 _unlock_limit) payable {
        require (msg.value != 0);
        require (_unlock_limit != 0);
        _start_date == block.timestamp;
        _owner = msg.sender;
        _unlock_limit = VALUE_LIMIT_UNLOCK_AMOUNT;
        _balance = _balance.add(msg.value);

        emit DepositOfEther(_owner, msg.value);
    }

    function FinaliseContractActivity () private OnlyOwner UnlockAmountSuccess {
        // Build in suicide function to kill all contract functions.

    }

    function EtherDepo() public payable {
        require (MIN_DEPO_AMOUNT >= msg.value && 
        msg.value <= MAX_DEPO_AMOUNT);
        _balance = _balance.add(msg.value);
        if (_balance >= VALUE_LIMIT_UNLOCK_AMOUNT) {
            emit DepositOfEther(msg.sender, msg.value);
            emit UnlockAmountAcheived((_balance), block.timestamp);
        } else {
            emit DepositOfEther(msg.sender, msg.value);
        }
    }

    function WithdrawEther(uint256 _amount) public OnlyOwner UnlockAmountSuccess {
        require (_amount != 0);
        address payable _to = payable(_owner);
        _balance = _balance.sub(_amount);
        (_to).transfer(_amount);
        if (_balance.sub(_amount) == 0) {
            FinaliseContractActivity();
            }

         emit AmountWithdrawn(_owner, _amount);

    }    

}