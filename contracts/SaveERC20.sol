// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SaveERC20 {
    address savingToken;
    address owner;

    mapping(address => uint256) savings;
    mapping(address => uint256) etherSavings;

    event SavingSuccessful(address sender, uint256 amount);
    event WithdrawSuccessful(address receiver, uint256 amount);

    constructor(address _savingToken) {
        savingToken = _savingToken;
        owner = msg.sender;
    }

    // Deposit Ethers(ETH)
    function depositEthers() external payable {
        require(msg.sender != address(0), "wrong EOA");
        require(msg.value > 0, "can't save zero value");
        etherSavings[msg.sender] = etherSavings[msg.sender] + msg.value;
        emit SavingSuccessful(msg.sender, msg.value);
    }

    // Deposit ERC20 Token
    function deposit(uint256 _amount) external {
        require(msg.sender != address(0), "address zero detected");
        require(_amount > 0, "can't save zero value");
        require(
            IERC20(savingToken).balanceOf(msg.sender) >= _amount,
            "not enough token"
        );

        require(
            IERC20(savingToken).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "failed to transfer"
        );

        savings[msg.sender] += _amount;

        emit SavingSuccessful(msg.sender, _amount);
    }

    // Withdraw for Ethers
    function withdrawEthers() external {
        require(msg.sender != address(0), "wrong EOA");
        uint256 _userEtherSavings = etherSavings[msg.sender];
        require(_userEtherSavings > 0, "you don't have any savings");

        etherSavings[msg.sender] -= _userEtherSavings;

        payable(msg.sender).transfer(_userEtherSavings);
    }

    // Withdraw for ERC-20
    function withdraw(uint256 _amount) external {
        require(msg.sender != address(0), "address zero detected");
        require(_amount > 0, "can't withdraw zero value");

        uint256 _userSaving = savings[msg.sender];

        require(_userSaving >= _amount, "insufficient funds");

        savings[msg.sender] -= _amount;

        require(
            IERC20(savingToken).transfer(msg.sender, _amount),
            "failed to withdraw"
        );

        emit WithdrawSuccessful(msg.sender, _amount);
    }

    // Ethers Savings check
    function checkEtherSavings(address _user) external view returns (uint256) {
        return etherSavings[_user];
    }

    // Checking ERC-20 Balance
    function checkUserBalance(address _user) external view returns (uint256) {
        return savings[_user];
    }

    function checkContractBalance() external view returns (uint256) {
        return IERC20(savingToken).balanceOf(address(this));
    }

    function checkContractEtherBal() external view returns (uint256) {
        return address(this).balance;
    }

    function ownerWithdraw(uint256 _amount) external {
        require(msg.sender == owner, "not owner");

        IERC20(savingToken).transfer(msg.sender, _amount);
    }

    function ownerAddress() external view returns (address) {
        return owner;
    }
}
