// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Access is AccessControl {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MERKLE_SETTER_ROLE = keccak256("MERKLE_SETTER_ROLE");
    bytes32 public constant EMERGENCY_WITHDRAWER_ROLE = keccak256("EMERGENCY_WITHDRAWER_ROLE");

    bool public paused;
    uint256 public totalVaultValue;

    address[] public owners;
    uint256 public threshold;

    event PauseToggled(bool isPaused);

    constructor(address[] memory _owners, uint256 _threshold) payable {

        require(_owners.length > 0, "No owners provided");
        require(_threshold > 0 && _threshold <= _owners.length, "Invalid threshold");

        threshold = _threshold;

        for (uint256 i = 0; i < _owners.length; i++) {
            address o = _owners[i];
            require(o != address(0), "Invalid owner");

            _grantRole(OWNER_ROLE, o);
            _grantRole(PAUSER_ROLE, o);
            _grantRole(MERKLE_SETTER_ROLE, o);
            _grantRole(EMERGENCY_WITHDRAWER_ROLE, o);

            owners.push(o);
        }

        totalVaultValue = msg.value;
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        paused = true;
        emit PauseToggled(true);
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        paused = false;
        emit PauseToggled(false);
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
}