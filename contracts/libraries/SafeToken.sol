// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

library SafeToken {
  function safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{ value: value }(new bytes(0));
    require(success, "safeTransferETH: ETH transfer failed");
  }
}
