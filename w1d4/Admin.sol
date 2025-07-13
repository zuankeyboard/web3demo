// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IBank.sol";

//编写一个 Admin 合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。

contract Admin {
    address public owner;

    // constructor {
    constructor() {
        owner = msg.sender;
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
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        // (bool success, ) = owner.calldata()
        // (bool success, ) = owner.call(){}
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Withdraw fail");
    }

    // receive() external payable;
    receive() external payable{}
}