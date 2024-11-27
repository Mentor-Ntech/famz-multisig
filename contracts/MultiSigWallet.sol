// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    address[] public owners;
    uint public requiredApprovals;
    mapping(address => bool) public isOwner;
    mapping(uint => Transaction) public transactions;
    uint public transactionCount;

    struct Transaction {
        address to;
        uint value;
        bool executed;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactionId < transactionCount, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed, "Transaction already executed");
        _;
    }

    modifier notApproved(uint transactionId) {
        require(!transactions[transactionId].approvals[msg.sender], "Transaction already approved by you");
        _;
    }

    constructor(address[] memory _owners, uint _requiredApprovals) {
        require(_owners.length >= 2, "At least 2 owners are required");
        require(_requiredApprovals <= _owners.length, "Required approvals cannot exceed the number of owners");

        owners = _owners;
        requiredApprovals = _requiredApprovals;

        for (uint i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
        }
    }

    function submitTransaction(address to, uint value) external onlyOwner {
        uint transactionId = transactionCount++;
        Transaction storage transaction = transactions[transactionId];
        transaction.to = to;
        transaction.value = value;
        transaction.executed = false;
        transaction.approvalCount = 0;
    }

    function approveTransaction(uint transactionId) 
        external 
        onlyOwner 
        transactionExists(transactionId) 
        notExecuted(transactionId) 
        notApproved(transactionId)
    {
        Transaction storage transaction = transactions[transactionId];
        transaction.approvals[msg.sender] = true;
        transaction.approvalCount++;

        if (transaction.approvalCount >= requiredApprovals) {
            executeTransaction(transactionId);
        }
    }

    function executeTransaction(uint transactionId) 
        internal 
        transactionExists(transactionId) 
        notExecuted(transactionId)
    {
        Transaction storage transaction = transactions[transactionId];
        require(transaction.approvalCount >= requiredApprovals, "Not enough approvals");

        transaction.executed = true;
        payable(transaction.to).transfer(transaction.value);
    }

    function getTransactionCount() external view returns (uint) {
        return transactionCount;
    }

    // Fallback function to accept Ether
    receive() external payable {}
}
