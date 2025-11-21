// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Lesson8_EventsBank {

    mapping(address => uint256) public balances;

    // ====== 定义事件 ======
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // 存款
    function deposit() external payable {
        require(msg.value > 0, "no zero value");

        balances[msg.sender] += msg.value;

        // 发射事件
        emit Deposit(msg.sender, msg.value);
    }

    // 取款
    function withdraw(uint256 amount) external {
        require(amount > 0, "invalid amount");
        require(balances[msg.sender] >= amount, "not enough");

        balances[msg.sender] -= amount;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "withdraw failed");

        // 发射事件
        emit Withdraw(msg.sender, amount);
    }
}
