// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EventBank {

    mapping(address => uint256) public balanceOf;

    // === Event 定义 ===
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // 存款
    function deposit() external payable {
        require(msg.value > 0, "Must send ETH");

        balanceOf[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value); // 触发事件
    }

    // 取款
    function withdraw(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Not enough balance");

        balanceOf[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount); // 触发事件
    }
}
