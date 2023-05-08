// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

interface IPoolAddressesProvider {
  function getPool() external view returns (address);
}
