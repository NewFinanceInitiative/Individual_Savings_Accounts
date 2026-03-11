// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface Interface_IndividualSavingsAccount {

    function DepositETH() external payable;
    function WithdrawETH(address _too, uint256 _amount) external;
    function GetBalance() external returns (uint256);
    function ChangeOwner(address _newOwner) external;

}