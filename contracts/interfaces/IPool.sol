// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

interface IPool {
  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint[] calldata amounts,
    uint[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;
}
