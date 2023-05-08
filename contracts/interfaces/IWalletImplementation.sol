// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

import "./IPoolAddressesProvider.sol";

interface IWalletImplementation {
  function initialize(IPoolAddressesProvider _provider, address _owner) external;
}
