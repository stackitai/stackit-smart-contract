// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./interfaces/IPoolAddressesProvider.sol";
import "./interfaces/IPool.sol";
import "./interfaces/IFlashLoanReceiver.sol";
import "./interfaces/IStack.sol";
import "./interfaces/IWallet.sol";

interface IUniswapV2Router02 {
  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);

  function WETH() external pure returns (address);
}

/**
 * @title WalletImplementation
 * @dev This contract is logic for the wallet contract
 */
contract WalletImplementation is IWallet, IFlashLoanReceiver {
  using SafeMath for uint256;
  using Address for address;
  using SafeERC20 for IERC20;

  /**
   * @dev Adress of the stack contract
   */
  address public override stack;
  /**
   * @dev Address of the owner
   */
  address public owner;
  /**
   * @dev Address of the addresses provider
   */
  IPoolAddressesProvider public ADDRESSES_PROVIDER;
  /**
   * @dev Address of the pool contract
   */
  IPool public POOL;

  /**
   * @dev Array of addresses to which the transaction is sent
   */
  address[] private _to;
  /**
   * @dev Array of data to be sent in the transaction
   */
  bytes[] private _data;
  /**
   * @dev Array of values to be sent in the transaction
   */
  uint256[] private _value;

  /**
   * @dev Initializes the wallet
   * @param _provider Address of the addresses provider
   * @param _owner Address of the owner
   */
  function initialize(IPoolAddressesProvider _provider, address _owner) external {
    require(msg.sender == stack, "Wallet::initialize: FORBIDDEN");
    ADDRESSES_PROVIDER = _provider;
    POOL = IPool(_provider.getPool());
    owner = _owner;
    address swapper = IStack(stack).swapper();
    address[] memory tokens = IStack(stack).getTokens();
    for (uint256 i = 0; i < tokens.length; i++) {
      SafeERC20.safeApprove(IERC20(tokens[i]), swapper, ~uint256(0));
    }
  }

  /**
   * @dev Executes the transaction
   * @param to Array of addresses to which the transaction is sent
   * @param data Array of data to be sent in the transaction
   * @param value Array of values to be sent in the transaction
   * @param token Address of the token to be swapped for ether
   * @param recipient Address of the recipient of the ether
   * @param gas Amount of ether to be sent to the recipient
   */
  function execute(
    address[] memory to,
    bytes[] memory data,
    uint256[] memory value,
    IERC20 token,
    address recipient,
    uint256 gas
  ) external payable {
    require(IStack(stack).hasDefaultAdminRole(msg.sender) || msg.sender == owner, "Wallet::execute: FORBIDDEN");
    _execute(to, data, value);
    if (gas != 0) {
      _swapTokenForEther(token, recipient, gas);
    }
  }

  /**
   * @dev Executes the transaction
   * @param to Array of addresses to which the transaction is sent
   * @param data Array of data to be sent in the transaction
   * @param value Array of values to be sent in the transaction
   */
  function _execute(address[] memory to, bytes[] memory data, uint256[] memory value) private {
    for (uint256 i = 0; i < to.length; i++) {
      (bool success, ) = to[i].call{ value: value[i] }(data[i]);
      require(success, "Wallet::execute: FAILED");
    }
  }

  /**
   * @dev Swaps tokens for ether
   * @param token Address of the token
   * @param recipient Address of the recipient
   * @param amountOut Amount of ether to receive
   */
  function _swapTokenForEther(IERC20 token, address recipient, uint256 amountOut) private {
    IUniswapV2Router02 router = IUniswapV2Router02(IStack(stack).router());
    address[] memory path = new address[](2);
    path[0] = address(token);
    path[1] = router.WETH();
    uint256[] memory amounts = router.getAmountsIn(amountOut, path);
    uint256 amountIn = amounts[0];
    SafeERC20.safeApprove(token, address(router), amountIn);
    router.swapTokensForExactETH(amountOut, amountIn, path, recipient, block.timestamp);
  }

  /**
   * @dev Transfers tokens from the wallet to the recipient
   * @param token Address of the token
   * @param recipient Address of the recipient
   * @param amount Amount of tokens to transfer
   */
  function transfer(IERC20 token, address recipient, uint256 amount) external {
    require(IStack(stack).hasDefaultAdminRole(msg.sender) || msg.sender == owner, "Wallet::transfer: FORBIDDEN");
    SafeERC20.safeTransfer(token, recipient, amount);
  }

  /**
   * @dev Executes the transaction to flash loan tokens and save execution data to the wallet
   * @param to Array of addresses to which the transaction is sent
   * @param data Array of data to be sent in the transaction
   * @param value Array of values to be sent in the transaction
   */
  function quit(address[] memory to, bytes[] memory data, uint256[] memory value) external {
    require(IStack(stack).hasDefaultAdminRole(msg.sender) || msg.sender == owner, "Wallet::quit: FORBIDDEN");
    address[] memory tto = new address[](to.length - 1);
    bytes[] memory tdata = new bytes[](data.length - 1);
    uint256[] memory tvalue = new uint256[](value.length - 1);
    for (uint256 i = 1; i < to.length; i++) {
      tto[i - 1] = to[i];
      tdata[i - 1] = data[i];
      tvalue[i - 1] = value[i];
    }
    _to = tto;
    _data = tdata;
    _value = tvalue;
    (bool success, ) = to[0].call{ value: value[0] }(data[0]);
    require(success, "Wallet::quit: FAILED");
  }

  /**
   * @dev Executes the transaction after the quit to repay the flash loan and execute the saved transaction data
   * @param assets Array of addresses of the assets to be flashed
   * @param amounts Array of amounts of the assets to be flashed
   * @param premiums Array of premiums of the assets to be flashed
   * @param initiator Address of the initiator of the flash loan
   * @param params Additional parameters
   */
  function executeOperation(
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata premiums,
    address initiator,
    bytes calldata params
  ) external override returns (bool) {
    initiator;
    params;
    require(msg.sender == address(POOL), "Wallet::executeOperation: FORBIDDEN");
    _execute(_to, _data, _value);
    _to = new address[](0);
    _data = new bytes[](0);
    _value = new uint256[](0);
    for (uint i = 0; i < assets.length; i++) {
      uint amountOwing = amounts[i].add(premiums[i]);
      IERC20(assets[i]).approve(address(POOL), amountOwing);
    }
    return true;
  }
}
