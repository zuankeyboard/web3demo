// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBank {
    // fucntion deposit();
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function admin() external view returns (address);
}