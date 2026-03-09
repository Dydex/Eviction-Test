// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Access.sol";
import "./MerkleClaim.sol";

contract Vault is Access, MerkleClaim {
    mapping(address => uint256) public balances;

    mapping(uint256 => Transaction) public transactions;
    uint256 public txCount;

    uint256 public constant TIMELOCK_DURATION = 1 hours;

    mapping(uint256 => mapping(address => bool)) public confirmed;

    event Submission(uint256 indexed txId);
    event Confirmation(uint256 indexed txId, address indexed owner);
    event Execution(uint256 indexed txId);

    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed withdrawer, uint256 amount);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
        uint256 submissionTime;
        uint256 executionTime;
    }

    function submitTransaction(address to, uint256 value, bytes calldata data) external onlyRole(OWNER_ROLE) whenNotPaused {
        uint256 id = txCount++;
        transactions[id] = Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: 1,
            submissionTime: block.timestamp,
            executionTime: 0
        });
        confirmed[id][msg.sender] = true;
        emit Submission(id);
    }

    function confirmTransaction(uint256 txId) external onlyRole(OWNER_ROLE) whenNotPaused {
        Transaction storage txn = transactions[txId];
        require(!txn.executed, "Already executed");
        require(!confirmed[txId][msg.sender], "Already confirmed");
        confirmed[txId][msg.sender] = true;
        txn.confirmations++;
        if (txn.confirmations == threshold) {
            txn.executionTime = block.timestamp + TIMELOCK_DURATION;
        }
        emit Confirmation(txId, msg.sender);
    }

    function executeTransaction(uint256 txId) external {
        Transaction storage txn = transactions[txId];
        require(txn.confirmations >= threshold, "Not enough confirmations");
        require(!txn.executed, "Already executed");
        require(txn.executionTime != 0, "Timelock not set");
        require(block.timestamp >= txn.executionTime, "Timelock not expired");
        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Transaction failed");
        emit Execution(txId);
    }

    function verifySignature(
        address signer,
        bytes32 messageHash,
        bytes memory signature
    ) external pure returns (bool) {
        return MerkleProof.recover(messageHash, signature) == signer;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        totalVaultValue += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalVaultValue += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external whenNotPaused {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        totalVaultValue -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawal(msg.sender, amount);
    }

    function emergencyWithdrawAll() external onlyRole(EMERGENCY_WITHDRAWER_ROLE) {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Transfer failed");
        totalVaultValue = 0;
    }
}

