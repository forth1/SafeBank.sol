// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title 简单拥有者合约
contract OwnableSimple {
    address public owner;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero addr");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/// @title 带余额的安全银行
contract SafeBankV2 {
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // 存款（任何人都可以调用）
    function deposit() external payable {
        require(msg.value > 0, "amount = 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // 取款（取自己存的钱）
    function withdraw(uint256 amount) external {
        require(amount > 0, "amount = 0");
        require(balances[msg.sender] >= amount, "balance not enough");

        balances[msg.sender] -= amount;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "ETH transfer failed");

        emit Withdraw(msg.sender, amount);
    }

    // 查询自己余额
    function getMyBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    // 查询合约里总 ETH
    function getBankTotal() external view returns (uint256) {
        return address(this).balance;
    }
}

/// @title 继承 Ownable + SafeBankV2 的版本
/// @notice 多了 onlyOwner 的紧急提款功能
contract SafeBankV2_Inherit is SafeBankV2, OwnableSimple {
    // 只有 owner 可以把合约所有 ETH 提出来（项目紧急关停用）
    function emergencyWithdrawAll() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "no ETH");

        (bool ok, ) = owner.call{value: bal}("");
        require(ok, "transfer failed");
    }
}
