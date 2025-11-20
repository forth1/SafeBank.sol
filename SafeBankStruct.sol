// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SafeBankStruct - 带用户信息（struct）的安全银行合约
contract SafeBankStruct {
    // ====== 1. 自定义结构体 ======
    struct Account {
        uint256 balance;        // 当前余额（合约内部记账）
        uint256 totalDeposit;   // 累计存入的总金额
        uint256 lastDepositAt;  // 最近一次存款时间戳
        string nickname;        // 用户昵称
        bool isVIP;             // 是否是 VIP 用户
    }

    // 每个地址对应一个 Account
    mapping(address => Account) private accounts;

    // 防重入锁
    bool private locked;

    // 合约 owner（比如银行管理员）
    address public owner;

    // ====== 2. 事件 ======
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event NicknameChanged(address indexed user, string newNickname);

    // ====== 3. 修饰符 ======
    modifier nonReentrant() {
        require(!locked, "Reentrancy blocked");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // ====== 4. 存款函数：顺便更新 struct ======
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be > 0");

        Account storage acc = accounts[msg.sender];

        acc.balance += msg.value;
        acc.totalDeposit += msg.value;
        acc.lastDepositAt = block.timestamp;

        // 简单规则：累计存入超 1 ETH 就是 VIP
        if (acc.totalDeposit >= 1 ether) {
            acc.isVIP = true;
        }

        emit Deposited(msg.sender, msg.value);
    }

    // ====== 5. 取款函数：防重入 + 更新余额 ======
    function withdraw(uint256 amount) external nonReentrant {
        Account storage acc = accounts[msg.sender];

        require(amount > 0, "Amount must be > 0");
        require(acc.balance >= amount, "Insufficient balance");

        // 先改状态，再转账（Checks-Effects-Interactions）
        acc.balance -= amount;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "Withdraw failed");

        emit Withdrawn(msg.sender, amount);
    }

    // ====== 6. 设置昵称 ======
    function setNickname(string calldata _nickname) external {
        Account storage acc = accounts[msg.sender];
        acc.nickname = _nickname;

        emit NicknameChanged(msg.sender, _nickname);
    }

    // ====== 7. 查询自己的信息 ======
    function getMyAccount()
        external
        view
        returns (
            uint256 balance,
            uint256 totalDeposit,
            uint256 lastDepositAt,
            string memory nickname,
            bool isVIP
        )
    {
        Account storage acc = accounts[msg.sender];
        return (
            acc.balance,
            acc.totalDeposit,
            acc.lastDepositAt,
            acc.nickname,
            acc.isVIP
        );
    }

    // ====== 8. 管理员可以查看任意用户信息 ======
    function getAccount(address user)
        external
        view
        onlyOwner
        returns (
            uint256 balance,
            uint256 totalDeposit,
            uint256 lastDepositAt,
            string memory nickname,
            bool isVIP
        )
    {
        Account storage acc = accounts[user];
        return (
            acc.balance,
            acc.totalDeposit,
            acc.lastDepositAt,
            acc.nickname,
            acc.isVIP
        );
    }

    // ====== 9. 查看合约里总余额（所有人存进来的 ETH） ======
    function getBankTotalBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
