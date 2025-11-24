// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UserRegistry {

    // 每个用户的数据结构
    struct User {
        string nickname;             // 昵称
        address primaryWallet;       // 主钱包
        address[] wallets;           // 绑定的钱包列表
        bool exists;                 // 是否已经注册
    }

    // 用户地址 → 用户信息
    mapping(address => User) public users;

    // 账号必须存在
    modifier onlyRegistered() {
        require(users[msg.sender].exists, "Account not registered");
        _;
    }

    // === 1. 注册账号 ===
    function register(string memory _nickname) external {
        require(!users[msg.sender].exists, "Already registered");

        users[msg.sender].exists = true;
        users[msg.sender].nickname = _nickname;
        users[msg.sender].primaryWallet = msg.sender;
        users[msg.sender].wallets.push(msg.sender);
    }

    // === 2. 修改昵称 ===
    function setNickname(string memory _name) external onlyRegistered {
        users[msg.sender].nickname = _name;
    }

    // === 3. 添加一个新的钱包地址 ===
    function addWallet(address _wallet) external onlyRegistered {
        require(_wallet != address(0), "Invalid address");

        users[msg.sender].wallets.push(_wallet);
    }

    // === 4. 删除钱包地址（按 index 删除）===
    function removeWallet(uint index) external onlyRegistered {
        require(index < users[msg.sender].wallets.length, "Index out of range");

        uint last = users[msg.sender].wallets.length - 1;
        users[msg.sender].wallets[index] = users[msg.sender].wallets[last];
        users[msg.sender].wallets.pop();
    }

    // === 5. 获取用户的全部信息 ===
    function getMyInfo() external view onlyRegistered returns (
        string memory,
        address,
        address[] memory
    ) {
        User storage u = users[msg.sender];
        return (u.nickname, u.primaryWallet, u.wallets);
    }
}
