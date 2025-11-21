// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Lesson9WalletDemo {

    event Received(address indexed sender, uint amount);
    event FallbackCalled(address indexed sender, uint amount, bytes data);

    // 查询合约 ETH 余额
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    // 可接收 ETH 的函数
    function deposit() external payable {
        require(msg.value > 0, "no ETH sent");
        emit Received(msg.sender, msg.value);
    }

    // receive —— 直接转账触发
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // fallback —— 调用不存在的函数时触发
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }
}
