// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

interface IStack {
  function owner() external view returns (address);

  function isExists(address _account) external view returns (bool);

  function router() external view returns (address);

  function swapper() external view returns (address);

  function getTokens() external view returns (address[] memory);

  function implementation() external view returns (address);

  function hasDefaultAdminRole(address _account) external view returns (bool);
}
