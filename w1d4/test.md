// 伪代码，展示交互流程

// 1. 部署合约
bigBank = deploy BigBank()
admin = deploy Admin()

// 2. 转移 BigBank 的管理员权限
bigBank.transferAdmin(admin.address)

// 3. 模拟用户存款 (必须 >0.001 ETH)
user1.sendTransaction({to: bigBank.address, value: 0.002 ether})
user2.sendTransaction({to: bigBank.address, value: 0.003 ether})

// 4. Admin 的 owner 提取资金
admin.adminWithdraw(bigBank.address, 0.004 ether)

// 5. 将资金从 Admin 合约提取到 owner 地址
admin.withdrawFunds(0.004 ether)