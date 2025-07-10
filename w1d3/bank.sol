// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
// 在 Bank 合约记录每个地址的存款金额
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户

contract Bank {
    // 管理员地址
    address public admin;
    
    // mapping(address -> )
    // mapping(address => int) public addressToAmount;
    // 每个地址的存款金额
    mapping(address => uint256) public addressToAmount;
    address[3] public topDepositors;

    // constructor {
    constructor() {
        admin = msg.sender;
        // addressToAmount[msg.sender] = msg.value; 若部署存款 则设置构造函数为payable
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin can call this function");
        _;  // 在函数之前执行
    }

    receive() external payable {
        deposit();
    }

    // function deposit() external payable {
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        addressToAmount[msg.sender] += msg.value;

        updateTopDepositors(msg.sender);
    }

    function updateTopDepositors(address addr) internal {
        uint256 addrToBalance = addressToAmount[addr];
        uint256 minIndex = 0;
        uint256 minBalance = addressToAmount[topDepositors[minIndex]];

        for (uint256 i = 0; i < 3; ++i) {
            address currentAddr = topDepositors[i];
            uint256 currentBalance = addressToAmount[currentAddr];

            if (currentBalance < minBalance) {
                minBalance = currentBalance;
                minIndex = i;
            }
        }

        if (addrToBalance > minBalance) {
            topDepositors[minIndex] = addr;
        }
    }

    // function withdraw() onlyAdmin {
    function withdraw(uint256 amount) external onlyAdmin {
        require(amount > 0, "Withdrawl amount must be greater than 0");
        // require(amount <= addressToAmount[msg.sender], "No sufficient balance)
        // require(amout <= addressToAmount[admin], "No sufficient balance");
        require(address(this).balance >= amount, "Insufficient contract balance");

        (bool success, ) = admin.call{value : amount}("");
        require(success, "Withdrawal failed.");

        // addressToAmount[msg.sender] -= amount; // 管理员存款后扣除
    
        // emit Withdrawl(amount);
    }

    function displayBalance() public view returns(address[3] memory, uint[3] memory) {
        uint256[3] memory balancesArr;

        for (uint256 i = 0; i < topDepositors.length; i ++ ) {
            balancesArr[i] = addressToAmount[topDepositors[i]] ;
        }

        return (topDepositors, balancesArr);
    }
}