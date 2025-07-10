// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Advanced Bank Contract
 * @dev Allows deposits, tracks top depositors, and has admin withdrawal functions
 */
contract Bank {
    // 管理员地址
    address public admin;
    
    // 记录每个地址的存款余额
    mapping(address => uint256) public balances;
    
    // 存储前3名存款用户的数组
    address[3] public topDepositors;
    
    // 存款事件
    event Deposit(address indexed account, uint256 amount);
    // 提款事件（仅管理员）
    event Withdrawal(address indexed admin, uint256 amount);
    
    /**
     * @dev 构造函数，设置管理员
     */
    constructor() {
        admin = msg.sender;
    }
    
    /**
     * @dev 修改器，限制只有管理员可以调用
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    
    /**
     * @dev 接收ETH的fallback函数
     */
    receive() external payable {
        deposit();
    }
    
    /**
     * @dev 存款函数
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        
        // 更新用户余额
        balances[msg.sender] += msg.value;
        
        // 更新前3名存款用户
        updateTopDepositors(msg.sender);
        
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev 内部函数，更新前3名存款用户
     * @param depositor 存款用户地址
     */
    function updateTopDepositors(address depositor) internal {
        uint256 currentBalance = balances[depositor];
        
        // 检查是否已经是前3名
        for (uint i = 0; i < 3; i++) {
            if (depositor == topDepositors[i]) {
                // 如果已经是前3名，只需重新排序
                sortTopDepositors();
                return;
            }
        }
        
        // 检查是否能进入前3名
        for (uint i = 0; i < 3; i++) {
            if (currentBalance > balances[topDepositors[i]]) {
                // 插入到合适位置
                for (uint j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j-1];
                }
                topDepositors[i] = depositor;
                break;
            }
        }
    }
    
    /**
     * @dev 内部函数，对前3名存款用户进行排序
     */
    function sortTopDepositors() internal {
        for (uint i = 0; i < 2; i++) {
            for (uint j = 0; j < 2 - i; j++) {
                if (balances[topDepositors[j]] < balances[topDepositors[j+1]]) {
                    address temp = topDepositors[j];
                    topDepositors[j] = topDepositors[j+1];
                    topDepositors[j+1] = temp;
                }
            }
        }
    }
    
    /**
     * @dev 管理员提取资金
     * @param amount 要提取的金额(wei)
     */
    function withdraw(uint256 amount) external onlyAdmin {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        (bool success, ) = admin.call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit Withdrawal(admin, amount);
    }
    
    /**
     * @dev 获取调用者的余额
     * @return 余额(wei)
     */
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    
    /**
     * @dev 获取合约的总余额
     * @return 合约持有的总ETH(wei)
     */
    function getTotalBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev 获取前3名存款用户
     * @return 包含前3名地址的数组
     */
    function getTopDepositors() public view returns (address[3] memory) {
        return topDepositors;
    }
}