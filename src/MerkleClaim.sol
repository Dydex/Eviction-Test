// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./Access.sol";

contract MerkleClaim is Access {

    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;

    event MerkleRootSet(bytes32 indexed newRoot);
    event Claim(address indexed claimant, uint256 amount);

    constructor(address[] memory _owners, uint256 _threshold)
        Access(_owners, _threshold)
    {}

    function setMerkleRoot(bytes32 root)
        external
        onlyRole(MERKLE_SETTER_ROLE)
    {
        merkleRoot = root;
        emit MerkleRootSet(root);
    }

    function claim(bytes32[] calldata proof, uint256 amount)
        external
        whenNotPaused
    {
        require(!claimed[msg.sender], "Already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        bytes32 computed = MerkleProof.processProof(proof, leaf);

        require(computed == merkleRoot, "Invalid proof");

        claimed[msg.sender] = true;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        totalVaultValue -= amount;

        emit Claim(msg.sender, amount);
    }
}