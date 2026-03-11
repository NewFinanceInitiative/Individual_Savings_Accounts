// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import"./SafeMaths.sol";
import"./Interface_ISA.sol";
import"./IERC20.sol";


contract IndividualSavingsAccount is IIndividualSavingsAccount {

    // Types of ISA based smart contrcats to be developed.

    // 1: Ether based only.
    // 2: Ether based only with dynamic deposits and withdrawals.
    // 3: Ether based only with set deposits and withdrawals.

    using SafeMath for uint256;

    uint256 internal balance;
    uint256 public time_locked;

    address public owner;

    mapping (address => uint) erc20balance;

    event DepositOfETH(address _from, uint256 _amount);
    event DepositOfTokens(address _token, address _from, uint256 _amount);
    event WithdrawalOfETH(address _too, uint256 _amount);
    event WithdrawalOfTokens(address _token, address _too, uint256 _amount);
    event LockedForLonger(uint256 _newTimeLocked);
    event ChangeOfOwnership(address _newOwner);

    modifier OnlyOwner() {
        require (msg.sender == owner);
        _;
    }

    modifier Locked() {
        if (time_locked >= block.timestamp) {
            revert();
        }
        _;
    }

    constructor (uint256 _timeLocked) payable {
        balance = msg.value;
        time_locked = _timeLocked;
        owner = msg.sender;
    }
    
    function DepositETH() public payable override {
        require (msg.value > 0);
        balance = balance.add(msg.value);
        emit DepositOfETH(msg.sender, msg.value);
    }

    // 2: Change deposit lots to be dynamic at the choice of the consumer that owns the ISA (this can have other functions in the smart contract that enable dynamics
    // savings options in the smart contract).

    function DepositERC20Tokens(address _token, uint256 _amount) public override {
        require (_amount > 0);
        erc20interface _erc20interface = erc20interface(_token);
        _erc20interface.transferFrom(msg.sender, address(this), _amount);
        erc20balance[_token] = erc20balance[_token].add(_amount);
        emit DepositOfTokens(_token, msg.sender, _amount);
    }
    

    // 1: Change the functionality of the withdrawal amounts to determine lots of currency to save and lock up. This means to implement dynamic parameters for 
    // balance thresholds that have been targeted from deposits.

    // 3: Add functions to set different withdrawal wallets and allow withdrawal to a chosen wallet.

    function WithdrawETH(address _too, uint256 _amount) public override OnlyOwner() Locked() {
        require (_amount > 0);
        payable(_too).transfer(_amount);
        balance = balance.sub(_amount); 
        emit WithdrawalOfETH(_too, _amount);
    }

    function WithdrawERC20Tokens(address _token, address _too, uint256 _amount) public override OnlyOwner() Locked() {
        require (_amount > 0);
        erc20interface _erc20interface = erc20interface(_token);
        _erc20interface.transfer(_too, _amount);
        erc20balance[_token] = erc20balance[_token].sub(_amount);  
        emit WithdrawalOfTokens(_token, _too, _amount);
    }

    function GetBalance() public view override returns (uint256) {
        return balance;
    }

    function GetERC20TokenBalance(address _token) public view returns (uint256) {
        return erc20balance[_token];
    }

    function LockForLonger(uint256 _timeLocked) public override OnlyOwner() {
        require (_timeLocked > time_locked);
        time_locked = _timeLocked;
        emit LockedForLonger(_timeLocked);
    }
    
    // 4: Add function to add more withdrawal wallets, these can act as owners too, depending on what type of ISA.

    function ChangeOwner(address _newOwner) public override OnlyOwner() {
        owner = _newOwner;
        emit ChangeOfOwnership(_newOwner);
    }


}