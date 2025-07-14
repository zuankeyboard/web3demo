// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IBank.sol";

//编写一个 Admin 合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。

contract Admin {
    // 新增事件
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event BankWithdrawal(address indexed bank, uint256 amount);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    address public owner;

    // constructor {
    constructor() {
        owner = msg.sender;

        emit OwnershipTransferred(address(0), owner); // 记录初始所有者
    }

    modifier onlyOwner {
        require(owner == msg.sender, "Only owner can call this function");
        // _
        _;
    }

    // function adminWithdraw(IBank bank) {
    function adminWithdraw(IBank bank, uint256 amount) external payable onlyOwner {
        require(address(bank) != address(0), "Bank address cannot be zero");
        // require(bank.admin() == this.address);
        require(bank.admin() == address(this), "This contract is not the admin of the bank");

        bank.withdraw(amount);
        emit BankWithdrawal(address(bank), amount); // 记录从银行提款
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        // (bool success, ) = owner.calldata()
        // (bool success, ) = owner.call(){}
        (bool success, ) = owner.call{value: amount}("");
        // (bool success, ) = owner.call{value: amount * 10 ** 18}("");
        require(success, "Withdraw fail");

        emit FundsWithdrawn(owner, amount); // 记录资金提取
    }

    // receive() external payable;
    receive() external payable{}
}