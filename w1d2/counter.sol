// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    // 状态变量
    uint256 public counter;

    // 获取 counter 的值 不修改 不消耗链上资源
    function get() public view returns (uint256) {
        return counter;
    }

    // 给 counter 增加 x
    function add(uint256 x) public {
        counter += x;
    }

}