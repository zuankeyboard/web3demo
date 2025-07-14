// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Bank.sol";

contract BigBank is Bank {
    // 新增事件
    event MinimumDepositChanged(uint256 newMinimum);

    modifier minimumDeposit() {
        require(msg.value > 0.001 ether, "Deposit must be greater than 0.001 ether");
        // require(msg.value / 1 * 10 ** 18 > 0.001 ether, "Deposit must be greater than 0.001 ether");
        // require(msg.value / (10 ** 18) > 0.001 ether, "Deposit must be greater than 0.001 ether");
        _;
    }

    function deposit() public payable override minimumDeposit {
        super.deposit();
    }

    function transferadmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "New admin cannot be zero address");
        emit AdminTransferred(admin, newAdmin);
        admin = newAdmin;

        // 先记录 后变更
        // emit AdminTransferred(address(0), newAdmin);
        // emit AdminTransferred(admin, newAdmin);
    }
}