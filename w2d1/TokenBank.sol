// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 题目#1
// 编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

// TokenBank 有两个方法：

// deposit() : 需要记录每个地址的存入数量；
// withdraw（）: 用户可以提取自己的之前存入的 token。

import "./BaseERC20.sol";

contract TokenBank {
    BaseERC20 public token;
    mapping(address => uint256) public deposits;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    // constructor TokenBank {
    constructor(address _tokenAddress) {
        token = BaseERC20(_tokenAddress);
    }

    function deposit(uint256 amount) external {
        // Transfer tokens from user to this contract
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );


        // Update deposit balance
        deposits[msg.sender] += amount;

        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        // Check if user has enough deposited
        require(deposits[msg.sender] >= amount, "Insufficient balance");

        // Update deposit balance before transfer to prevent reentrancy
        deposits[msg.sender] -= amount;

        // Transfer tokens back to user
        require(
            token.transfer(msg.sender, amount),
            "Transfer failed"
        );

        emit Withdrawn(msg.sender, amount);
    }

    // Optional: View function to check user's deposited balance
    function getDepositBalance(address user) external view returns (uint256) {
        return deposits[user];
    }
}