# Eviction Vault Hardening

## Overview

This project refactors the original **EvictionVault** monolithic contract into a modular and secure architecture.  
The goal was to mitigate critical security vulnerabilities and improve maintainability while ensuring the contract compiles and passes basic tests.

The system now uses **role-based access control**, improved **fund transfer mechanisms**, and safer **multisig execution logic**.

---

# Project Structure

The original single-file contract was decomposed into multiple modules.


### Contracts

| Contract | Responsibility |
|--------|--------|
| `Access.sol` | Role management, pause system, owner configuration |
| `MerkleClaim.sol` | Merkle proof based claim system |
| `Vault.sol` | Multisig vault logic, deposits, withdrawals |

---

# Security Fixes Implemented

## 1. Unrestricted `setMerkleRoot`
### Issue
The original contract allowed **any address** to update the Merkle root.

### Fix
Restricted access using role-based permissions.

**onlyRole(MERKLE_SETTER_ROLE)**
---

## 2. Public `emergencyWithdrawAll`
### Issue
Anyone could drain the entire vault.

### Fix
Restricted the function to authorized addresses.

**onlyRole(EMERGENCY_WITHDRAWER_ROLE)**

---

## 3. `tx.origin` Usage
### Issue
Using `tx.origin` is unsafe and can enable phishing attacks.

### Fix
Replaced with `msg.sender`.

---

## 4. `.transfer()` Usage
### Issue
`.transfer()` has a fixed gas stipend and may fail due to gas changes.

### Fix
Replaced with a safer low-level call.
**(bool success, ) = payable(msg.sender).call{value: amount}("");**


---

## 5. Single Owner Pause Control
### Issue
Pause functionality relied on a single owner.

### Fix
Introduced **role-based pause control**.
**onlyRole(PAUSER_ROLE)**


Multiple trusted owners can now pause or unpause the contract.

---

## 6. Timelock Execution Hardening
### Issue
Transactions could potentially execute without a properly initialized timelock.

### Fix
Added validation checks before execution.


---

## 7. Multisig Security Improvements

Implemented:

- transaction submission
- owner confirmations
- threshold enforcement
- timelock execution delay

This ensures transactions require **multiple confirmations before execution**.

---

# Role Architecture

The system now uses **role-based permissions** via AccessControl.

| Role | Purpose |
|-----|------|
| `OWNER_ROLE` | Multisig participants |
| `PAUSER_ROLE` | Pause and unpause contract |
| `MERKLE_SETTER_ROLE` | Update Merkle root |
| `EMERGENCY_WITHDRAWER_ROLE` | Emergency vault withdrawals |

---


