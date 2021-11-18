// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract MyToken {
    uint256 balance;

    constructor() {
        balance = 0;
    }

    function getBalance() public view returns (uint256) {
        return balance;
    }

    function depositBalance(uint amount) public {
        balance += amount;
    }

    function withdrawBalance(uint amount) public {
        require(amount <= balance);
        balance -= amount;
    }
}
