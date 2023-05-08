// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./interfaces/IWalletImplementation.sol";

import "./Wallet.sol";

/**
 * @title Stack
 * @dev This contract is used to create wallets and keep track of all the wallets ever created
 */
contract Stack is Ownable, AccessControl {
  using SafeMath for uint256;
  using Address for address;
  using EnumerableSet for EnumerableSet.AddressSet;

  /**
   * @dev Mapping from account to wallet
   */
  mapping(address => address) public getWallet;
  /**
   * @dev All the wallets ever created
   */
  EnumerableSet.AddressSet private _allWallets;
  /**
   * @dev Address of the router contract
   */
  address public router;
  /**
   * @dev Address of the swapper contract
   */
  address public swapper;
  /**
   * @dev Address of the addresses provider
   */
  IPoolAddressesProvider public ADDRESSES_PROVIDER;
  /**
   * @dev Array of supported tokens
   */
  address[] public tokens;
  /**
   * @dev Address of the implementation contract
   */
  address public implementation;

  /**
   * @dev Emitted when a wallet is created
   * @param account Account for which the wallet is created
   * @param wallet Address of the wallet
   * @param blockNumber Block number at which the wallet is created
   */
  event WalletCreated(address indexed account, address indexed wallet, uint256 blockNumber);
  /**
   * @dev Emitted when the implementation is changed.
   */
  event Upgraded(address indexed implementation);

  /**
   * @dev Initializes the contract
   * @param _router Address of the router contract
   * @param _swapper Address of the swapper contract
   * @param _provider Address of the addresses provider
   * @param _tokens Array of supported tokens
   */
  constructor(address _router, address _swapper, IPoolAddressesProvider _provider, address[] memory _tokens) public {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    router = _router;
    swapper = _swapper;
    ADDRESSES_PROVIDER = _provider;
    tokens = _tokens;
  }

  /**
   * @dev Creates a wallet for the caller
   */
  function createWallet() external returns (address wallet) {
    require(getWallet[msg.sender] == address(0), "Stack::createWallet: WALLET EXISTS");
    bytes memory bytecode = type(Wallet).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(msg.sender));
    assembly {
      wallet := create2(0, add(bytecode, 32), mload(bytecode), salt)
    }
    IWalletImplementation(payable(wallet)).initialize(ADDRESSES_PROVIDER, msg.sender);
    getWallet[msg.sender] = wallet;
    _allWallets.add(wallet);
    emit WalletCreated(msg.sender, wallet, block.number);
  }

  /**
   * @dev Checks if the account has a wallet
   * @param _account Account to check
   */
  function isExists(address _account) external view returns (bool) {
    return _allWallets.contains(_account);
  }

  /**
   * @dev Gets supported tokens
   */
  function getTokens() external view returns (address[] memory) {
    return tokens;
  }

  /**
   * @dev Checks if the account has the default admin role
   * @param _account Account to check
   */
  function hasDefaultAdminRole(address _account) external view returns (bool) {
    return hasRole(DEFAULT_ADMIN_ROLE, _account);
  }

  /**
   * @dev Sets the implementation contract address
   *
   * Requirements:
   *
   * - `_implementation` must be a contract.
   */
  function setImplementation(address _implementation) external onlyOwner {
    require(Address.isContract(_implementation), "Stack::setImplementation: INVALID IMPLEMENTATION");
    implementation = _implementation;
    emit Upgraded(implementation);
  }
}
