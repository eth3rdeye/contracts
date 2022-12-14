// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct Session  {
  bytes32 targetCommitment;
  string target;
  uint startedAt;
  address tasker;
}
