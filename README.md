# EvictionVault Smart Contract - Security Refactor & Modular Architecture

## Overview

This document details the comprehensive security refactoring and architectural improvements made to the **EvictionVault** smart contract. The original monolithic contract has been decomposed into a modular, secure architecture using **OpenZeppelin's AccessControl** for role-based permission management.

---

## Critical Vulnerabilities Fixed

### 1. 🔴 `setMerkleRoot()` — Callable by Anyone
**Severity:** CRITICAL  
**Original Issue:** No access control; any address could set the merkle root, allowing unauthorized claim verification.

**Fix:**
```solidity
function setMerkleRoot(bytes32 root) external onlyRole(MERKLE_SETTER_ROLE) {
    merkleRoot = root;
    emit MerkleRootSet(root);
}

