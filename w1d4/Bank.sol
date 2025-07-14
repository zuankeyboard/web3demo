// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 在 该挑战 的 Bank 合约基础之上，编写 IBank 接口及BigBank 合约，使其满足 Bank 实现 IBank， BigBank 继承自 Bank ， 同时 BigBank 有附加要求：

// 要求存款金额 >0.001 ether（用modifier权限控制）
// BigBank 合约支持转移管理员
// 编写一个 Admin 合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。

// BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址，模拟几个用户的存款，然后

// Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。

// import "./interfaces/Bank.sol"
import "./interfaces/IBank.sol";

// 可以通过 Metamask 等钱包直接给 Bank 合约地址存款
// 在 Bank 合约记录每个地址的存款金额
// 编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
// 用数组记录存款金额的前 3 名用户

contract Bank is IBank {
    // 新增事件
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed admin, uint256 amount);
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

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

        // emit AdminTransferred(address(0), admin);
        emit AdminTransferred(address(0), msg.sender);  // 记录初始管理员
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin can call this function");
        _;  // 在函数之前执行
    }

    receive() external payable {
        deposit(); // 安全调用 public 函数
    }

    // function deposit() external payable {
    // function deposit() public payable {
    // function deposit() public payable virtual {
    // function deposit() external payable virtual {
    function deposit() public payable virtual {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        addressToAmount[msg.sender] += msg.value;

        updateTopDepositors(msg.sender);

        emit Deposited(msg.sender, msg.value);
    }

    function updateTopDepositors(address addr) internal {
        uint256 addrToBalance = addressToAmount[addr];
        uint256 minIndex = 0;
        uint256 minBalance = addressToAmount[topDepositors[minIndex]];

        for (uint256 i = 0; i < 3; ++i) {
            address currentAddr = topDepositors[i];

            // 若当前地址在 top3 里不需要更新 直接退出
            if (addr == currentAddr) return;

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
    // function withdraw(uint256 amount) external onlyAdmin {
    function withdraw(uint256 amount) external virtual onlyAdmin {
        require(amount > 0, "Withdrawl amount must be greater than 0");
        // require(amount <= addressToAmount[msg.sender], "No sufficient balance)
        // require(amout <= addressToAmount[admin], "No sufficient balance");
        require(address(this).balance >= amount, "Insufficient contract balance");

        (bool success, ) = admin.call{value : amount}("");
        // (bool success, ) = admin.call{value : amount * 10 ** 18}("");
        require(success, "Withdrawal failed.");

        // addressToAmount[msg.sender] -= amount; // 管理员存款后扣除
    
        // emit Withdrawl(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function displayBalance() public view returns(address[3] memory, uint[3] memory) {
        uint256[3] memory balancesArr;

        for (uint256 i = 0; i < topDepositors.length; i ++ ) {
            balancesArr[i] = addressToAmount[topDepositors[i]] ;
        }

        return (topDepositors, balancesArr);
    }
}


// // 内部实现逻辑
// function _processDeposit() internal {
//     require(msg.value > 0, "Deposit amount must be greater than 0");
//     addressToAmount[msg.sender] += msg.value;
//     updateTopDepositors(msg.sender);
// }

// // 外部接口
// function deposit() external payable {
//     _processDeposit();
// }

// receive() external payable {
//     _processDeposit();
// }