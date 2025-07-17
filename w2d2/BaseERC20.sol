// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 题目#1
// 编写 ERC20 token 合约
  
// 介绍
// ERC20 是以太坊区块链上最常用的 Token 合约标准。通过这个挑战，你不仅可以熟悉 Solidity 编程，而且可以了解 ERC20 Token 合约的工作原理。

// 目标
// 完善合约，实现以下功能：

// 设置 Token 名称（name）："BaseERC20"
// 设置 Token 符号（symbol）："BERC20"
// 设置 Token 小数位decimals：18
// 设置 Token 总量（totalSupply）:100,000,000
// 允许任何人查看任何地址的 Token 余额（balanceOf）
// 允许 Token 的所有者将他们的 Token 发送给任何人（transfer）；转帐超出余额时抛出异常(require),并显示错误消息 “ERC20: transfer amount exceeds balance”。
// 允许 Token 的所有者批准某个地址消费他们的一部分Token（approve）
// 允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）
// 允许被授权的地址消费他们被授权的 Token 数量（transferFrom）；
// 转帐超出余额时抛出异常(require)，异常信息：“ERC20: transfer amount exceeds balance”
// 转帐超出授权数量时抛出异常(require)，异常消息：“ERC20: transfer amount exceeds allowance”。
// 注意：
// 在编写合约时，需要遵循 ERC20 标准，此外也需要考虑到安全性，确保转账和授权功能在任何时候都能正常运行无误。
// 代码模板中已包含基础框架，只需要在标记为“Write your code here”的地方编写你的代码。不要去修改已有内容！

// 希望你能用一段优雅、高效和安全的代码，完成这个挑战。

// 扩展 ERC20 合约 ，添加一个有hook 功能的转账函数，如函数名为：transferWithCallback ，在转账时，如果目标地址是合约地址的话，调用目标地址的 tokensReceived() 方法。

contract BaseERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        // totalSupply = 100_000_000 * 1e18;
        totalSupply = 100000000 * (10 ** uint256(decimals));

        balances[msg.sender] = totalSupply;  
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        // require(allowances[_from][_to].)
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");

        balances[_from] -= _value;
        balances[_to] += _value;

        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here
        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here     
        return allowances[_owner][_spender];
    }

    // 新增：带回调的转账函数
    function transferWithCallback(address _to, uint256 _value) public returns (bool success) {
        require(balances[_to] >= _value, "ERC20: transfer amount exceeds balance");

        // 先执行转账（Checks-Effects-Interactions模式）
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        // 如果是合约地址，尝试调用tokensReceived()
        if (isContract(_to)) {
            // 使用call而不是直接调用，以防目标合约没有这个函数
            (bool callbackSuccess, ) = _to.call(
                abi.encodeWithSignature(
                    "tokensReceived(address,uint256)",
                    msg.sender,
                    _value
                )
            );
            // 不require回调成功，因为这不是转账的必要条件
            // 只是让接收方有机会知道收到了代币
        }

        return true;
    }

    // 辅助函数：检查地址是否是合约
    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            // size := extcodesize(_addr);
            size := extcodesize(_addr)
        }

        return (size > 0);
    }
}