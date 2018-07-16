pragma solidity ^0.4.19;
//pragma experimental ABIEncoderV2;


/**
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title TokenIOLib

@author Ryan Tate <ryan.michael.tate@gmail.com>, Sean Pollock <seanpollock3344@gmail.com>

@notice This library proxies the TokenIOStorage contract for the interface contract,
allowing the library and the interfaces to remain stateless, and share a universally
available storage contract between interfaces.


*/


import "./SafeMath.sol";
import "./TokenIOStorage.sol";


library TokenIOLib {

  /// @dev all math operating are using SafeMath methods to check for overflow/underflows
  using SafeMath for uint;

  /// @dev the Data struct uses the Storage contract for stateful setters
  struct Data {
    TokenIOStorage Storage;
  }

  event LogApproval(address indexed owner, address indexed spender, uint amount);
  event LogDeposit(string currency, address indexed account, uint amount, string issuerFirm);
  event LogWithdraw(string currency, address indexed account, uint amount, string issuerFirm);
  event LogTransfer(string currency, address indexed from, address indexed to, uint amount, bytes data);
  event LogKYCApproval(address indexed account, bool status, string issuerFirm);
  event LogAccountStatus(address indexed account, bool status, string issuerFirm);
  event LogFxSwap(string tokenASymbol,string tokenBSymbol,uint tokenAValue,uint tokenBValue, uint expiration, bytes32 transactionHash);
  event LogAccountForward(address indexed originalAccount, address indexed forwardedAccount);
  event LogNewAuthority(address indexed authority, string issuerFirm);

  /**
   * @notice Set the token name for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param tokenName Name of the token contract
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenName(Data storage self, string tokenName) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.name', address(this)));
    self.Storage.setString(id, tokenName);
    return true;
  }

  /**
   * @notice Set the token symbol for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param tokenSymbol Symbol of the token contract
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenSymbol(Data storage self, string tokenSymbol) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.symbol', address(this)));
    self.Storage.setString(id, tokenSymbol);
    return true;
  }

  /**
   * @notice Set the token three letter abreviation (TLA) for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param tokenTLA TLA of the token contract
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenTLA(Data storage self, string tokenTLA) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.tla', address(this)));
    self.Storage.setString(id, tokenTLA);
    return true;
  }

  /**
   * @notice Set the token version for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param tokenVersion Semantic (vMAJOR.MINOR.PATCH | e.g. v0.1.0) version of the token contract
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenVersion(Data storage self, string tokenVersion) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.version', address(this)));
    self.Storage.setString(id, tokenVersion);
    return true;
  }

  /**
   * @notice Set the token decimals for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @dev This method is not set to the address of the contract, rather is maped to currency
   * @dev To derive decimal value, divide amount by 10^decimal representation (e.g. 10132 / 10**2 == 101.32)
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param tokenDecimals Decimal representation of the token contract unit amount
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenDecimals(Data storage self, string currency, uint tokenDecimals) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.decimals', currency));
    self.Storage.setUint(id, tokenDecimals);
    return true;
  }

  /**
   * @notice Set basis point fee for contract interface
   * @dev Transaction fees can be set by the TokenIOFeeContract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeBPS Basis points fee for interface contract transactions
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeBPS(Data storage self, uint feeBPS) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.bps', address(this)));
    self.Storage.setUint(id, feeBPS);
    return true;
  }

  /**
   * @notice Set minimum fee for contract interface
   * @dev Transaction fees can be set by the TokenIOFeeContract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeMin Minimum fee for interface contract transactions
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeMin(Data storage self, uint feeMin) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.min', address(this)));
    self.Storage.setUint(id, feeMin);
    return true;
  }

  /**
   * @notice Set maximum fee for contract interface
   * @dev Transaction fees can be set by the TokenIOFeeContract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeMax Maximum fee for interface contract transactions
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeMax(Data storage self, uint feeMax) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.max', address(this)));
    self.Storage.setUint(id, feeMax);
    return true;
  }

  /**
   * @notice Set flat fee for contract interface
   * @dev Transaction fees can be set by the TokenIOFeeContract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeFlat Flat fee for interface contract transactions
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeFlat(Data storage self, uint feeFlat) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.flat', address(this)));
    self.Storage.setUint(id, feeFlat);
    return true;
  }

  /**
   * @notice Set fee contract for a contract interface
   * @dev feeContract must be a TokenIOFeeContract storage approved contract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev | This method has an `internal` view
   * @dev | This must be called directly from the interface contract
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeContract Set the fee contract for `this` contract address interface
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeContract(Data storage self, address feeContract) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.account', address(this)));
    self.Storage.setAddress(id, feeContract);
    return true;
  }

  /**
   * @notice Set contract interface associated with a given TokenIO currency symbol (e.g. USDx)
   * @dev | This should only be called once from a token interface contract;
   * @dev | This method has an `internal` view
   * @dev | This method is experimental and may be deprecated/refactored
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenNameSpace(Data storage self, string currency) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.namespace', currency));
    self.Storage.setAddress(id, address(this));
    return true;
  }

  /**
   * @notice Set the KYC approval status (true/false) for a given account
   * @dev | This method has an `internal` view
   * @dev | Every account must be KYC'd to be able to use transfer() & transferFrom() methods
   * @dev | To gain approval for an account, register at https://tsm.token.io/sign-up
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @param isApproved Boolean (true/false) KYC approval status for a given account
   * @param issuerFirm Firm name for issuing KYC approval
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setKYCApproval(Data storage self, address account, bool isApproved, string issuerFirm) internal returns (bool success) {
      bytes32 id = keccak256(abi.encodePacked('account.kyc', getForwardedAccount(self, account)));
      self.Storage.setBool(id, isApproved);

      /// @dev NOTE: Issuer is logged for setting account KYC status
      emit LogKYCApproval(account, isApproved, issuerFirm);
      return true;
  }

  /**
   * @notice Set the global approval status (true/false) for a given account
   * @dev | This method has an `internal` view
   * @dev | Every account must be permitted to be able to use transfer() & transferFrom() methods
   * @dev | To gain approval for an account, register at https://tsm.token.io/sign-up
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @param isAllowed Boolean (true/false) global status for a given account
   * @param issuerFirm Firm name for issuing approval
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setAccountStatus(Data storage self, address account, bool isAllowed, string issuerFirm) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('account.allowed', getForwardedAccount(self, account)));
    self.Storage.setBool(id, isAllowed);

    /// @dev NOTE: Issuer is logged for setting account status
    emit LogAccountStatus(account, isAllowed, issuerFirm);
    return true;
  }


  /**
   * @notice Set a forwarded address for an account.
   * @dev | This method has an `internal` view
   * @dev | Forwarded accounts must be set by an authority in case of account recovery;
   * @dev | Additionally, the original owner can set a forwarded account (e.g. add a new device, spouse, dependent, etc)
   * @dev | All transactions will be logged under the same KYC information as the original account holder;
   * @param self Internal storage proxying TokenIOStorage contract
   * @param originalAccount Original registered Ethereum address of the account holder
   * @param forwardedAccount Forwarded Ethereum address of the account holder
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setForwardedAccount(Data storage self, address originalAccount, address forwardedAccount) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('master.account', forwardedAccount));
    self.Storage.setAddress(id, originalAccount);
    return true;
  }

  /**
   * @notice Get the original address for a forwarded account
   * @dev | This method has an `internal` view
   * @dev | Will return the registered account for the given forwarded account
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @return { "registeredAccount" : "Will return the original account of a forwarded account or the account itself if no account found"}
   */
  function getForwardedAccount(Data storage self, address account) internal view returns (address registeredAccount) {
    bytes32 id = keccak256(abi.encodePacked('master.account', account));
    address originalAccount = self.Storage.getAddress(id);
    if (originalAccount != 0x0) {
      return originalAccount;
    } else {
      return account;
    }
  }

  /**
   * @notice Get KYC approval status for the account holder
   * @dev | This method has an `internal` view
   * @dev | All forwarded accounts will use the original account's status
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @return { "status" : "Returns the KYC approval status for an account holder" }
   */
  function getKYCApproval(Data storage self, address account) internal view returns (bool status) {
      bytes32 id = keccak256(abi.encodePacked('account.kyc', getForwardedAccount(self, account)));
      return self.Storage.getBool(id);
  }

  /**
   * @notice Get global approval status for the account holder
   * @dev | This method has an `internal` view
   * @dev | All forwarded accounts will use the original account's status
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @return { "status" : "Returns the global approval status for an account holder" }
   */
  function getAccountStatus(Data storage self, address account) internal view returns (bool status) {
    bytes32 id = keccak256(abi.encodePacked('account.allowed', getForwardedAccount(self, account)));
    return self.Storage.getBool(id);
  }

  /**
   * @notice Get the contract interface address associated with token symbol
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @return { "contractAddress" : "Returns the contract interface address for a symbol" }
   */
  function getTokenNameSpace(Data storage self, string currency) internal view returns (address contractAddress) {
    bytes32 id = keccak256(abi.encodePacked('token.namespace', currency));
    return self.Storage.getAddress(id);
  }

  /**
   * @notice Get the token name for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return {"tokenName" : "Name of the token contract"}
   */
  function getTokenName(Data storage self, address contractAddress) internal view returns (string tokenName) {
    bytes32 id = keccak256(abi.encodePacked('token.name', contractAddress));
    return self.Storage.getString(id);
  }

  /**
   * @notice Get the token symbol for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return {"tokenSymbol" : "Symbol of the token contract"}
   */
  function getTokenSymbol(Data storage self, address contractAddress) internal view returns (string tokenSymbol) {
    bytes32 id = keccak256(abi.encodePacked('token.symbol', contractAddress));
    return self.Storage.getString(id);
  }

  /**
   * @notice Get the token Three letter abbreviation (TLA) for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return {"tokenTLA" : "TLA of the token contract"}
   */
  function getTokenTLA(Data storage self, address contractAddress) internal view returns (string tokenTLA) {
    bytes32 id = keccak256(abi.encodePacked('token.tla', contractAddress));
    return self.Storage.getString(id);
  }

  /**
   * @notice Get the token version for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return {"tokenVersion" : "Semantic version of the token contract"}
   */
  function getTokenVersion(Data storage self, address contractAddress) internal view returns (string) {
    bytes32 id = keccak256(abi.encodePacked('token.version', contractAddress));
    return self.Storage.getString(id);
  }

  /**
   * @notice Get the token decimals for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @return {"tokenDecimals" : "Decimals of the token contract"}
   */
  function getTokenDecimals(Data storage self, string currency) internal view returns (uint tokenDecimals) {
    bytes32 id = keccak256(abi.encodePacked('token.decimals', currency));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the basis points fee of the contract address; typically TokenIOFeeContract
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeBps" : "Returns the basis points fees associated with the contract address"}
   */
  function getFeeBPS(Data storage self, address contractAddress) internal view returns (uint feeBps) {
    bytes32 id = keccak256(abi.encodePacked('fee.bps', contractAddress));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the minimum fee of the contract address; typically TokenIOFeeContract
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeMin" : "Returns the minimum fees associated with the contract address"}
   */
  function getFeeMin(Data storage self, address contractAddress) internal view returns (uint feeMin) {
    bytes32 id = keccak256(abi.encodePacked('fee.min', contractAddress));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the maximum fee of the contract address; typically TokenIOFeeContract
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeMax" : "Returns the maximum fees associated with the contract address"}
   */
  function getFeeMax(Data storage self, address contractAddress) internal view returns (uint feeMax) {
    bytes32 id = keccak256(abi.encodePacked('fee.max', contractAddress));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the flat fee of the contract address; typically TokenIOFeeContract
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeFlat" : "Returns the flat fees associated with the contract address"}
   */
  function getFeeFlat(Data storage self, address contractAddress) internal view returns (uint feeFlat) {
    bytes32 id = keccak256(abi.encodePacked('fee.flat', contractAddress));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Set the master fee contract used as the default fee contract when none is provided
   * @dev | This method has an `internal` view
   * @dev | This value is set in the TokenIOAuthority contract
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "success" : "Returns true when successfully called from another contract"}
   */
  function setMasterFeeContract(Data storage self, address contractAddress) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.contract.master'));
    require(self.Storage.setAddress(id, contractAddress));
    return true;
  }

  /**
   * @notice Get the master fee contract set via the TokenIOAuthority contract
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @return { "masterFeeContract" : "Returns the master fee contract set for TSM."}
   */
  function getMasterFeeContract(Data storage self) internal view returns (address masterFeeContract) {
    bytes32 id = keccak256(abi.encodePacked('fee.contract.master'));
    return self.Storage.getAddress(id);
  }

  /**
   * @notice Get the fee contract set for a contract interface
   * @dev | This method has an `internal` view
   * @dev | Custom fee pricing can be set by assigning a fee contract to transactional contract interfaces
   * @dev | If a fee contract has not been set by an interface contract, then the master fee contract will be returned
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeContract" : "Returns the fee contract associated with a contract interface"}
   */
  function getFeeContract(Data storage self, address contractAddress) internal view returns (address feeContract) {
    bytes32 id = keccak256(abi.encodePacked('fee.account', contractAddress));

    address feeAccount = self.Storage.getAddress(id);
    if (feeAccount == 0x0) {
      return getMasterFeeContract(self);
    } else {
      return feeAccount;
    }
  }

  /**
   * @notice Get the token supply for a given TokenIO TSM currency symbol (e.g. USDx)
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @return { "supply" : "Returns the token supply of the given currency"}
   */
  function getTokenSupply(Data storage self, string currency) internal view returns (uint supply) {
    bytes32 id = keccak256(abi.encodePacked('token.supply', currency));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the token spender allowance for a given account
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @param spender Ethereum address of spender
   * @return { "allowance" : "Returns the allowance of a given spender for a given account"}
   */
  function getTokenAllowance(Data storage self, string currency, address account, address spender) internal view returns (uint allowance) {
    bytes32 id = keccak256(abi.encodePacked('token.allowance', currency, getForwardedAccount(self, account), getForwardedAccount(self, spender)));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the token balance for a given account
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param account Ethereum address of account holder
   * @return { "balance" : "Return the balance of a given account for a specified currency"}
   */
  function getTokenBalance(Data storage self, string currency, address account) internal view returns (uint balance) {
    bytes32 id = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, account)));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the frozen token balance for a given account
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param account Ethereum address of account holder
   * @return { "frozenBalance" : "Return the frozen balance of a given account for a specified currency"}
   */
  function getTokenFrozenBalance(Data storage self, string currency, address account) internal view returns (uint frozenBalance) {
    bytes32 id = keccak256(abi.encodePacked('token.frozen', currency, getForwardedAccount(self, account)));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Set the frozen token balance for a given account
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param account Ethereum address of account holder
   * @param amount Amount of tokens to freeze for account
   * @return { "success" : "Return true if successfully called from another contract"}
   */
  function setTokenFrozenBalance(Data storage self, string currency, address account, uint amount) internal view returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.frozen', currency, getForwardedAccount(self, account)));
    require(self.Storage.setUint(id, amount));
    return true;
  }

  /**
   * @notice Set the frozen token balance for a given account
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the fee contract
   * @param amount Transaction value
   * @return { "calculatedFees" : "Return the calculated transaction fees for a given amount and fee contract" }
   */
  function calculateFees(Data storage self, address contractAddress, uint amount) internal view returns (uint calculatedFees) {

    uint maxFee = self.Storage.getUint(keccak256(abi.encodePacked('fee.max', contractAddress)));
    uint minFee = self.Storage.getUint(keccak256(abi.encodePacked('fee.min', contractAddress)));
    uint bpsFee = self.Storage.getUint(keccak256(abi.encodePacked('fee.bps', contractAddress)));
    uint flatFee = self.Storage.getUint(keccak256(abi.encodePacked('fee.flat', contractAddress)));
    uint fees = ((amount.mul(bpsFee)).div(10000)).add(flatFee);

    if (fees > maxFee) {
      return maxFee;
    } else if (fees < minFee) {
      return minFee;
    } else {
      return fees;
    }
  }

  /**
   * @notice Verified KYC and global status for two accounts and return true or throw if either account is not verified
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param accountA Ethereum address of first account holder to verify
   * @param accountB Ethereum address of second account holder to verify
   * @return { "verified" : "Returns true if both accounts are successfully verified" }
   */
  function verifyAccounts(Data storage self, address accountA, address accountB) internal returns (bool verified) {
    require(verifyAccount(self, accountA));
    require(verifyAccount(self, accountB));
    return true;
  }

  /**
   * @notice Verified KYC and global status for a single account and return true or throw if account is not verified
   * @dev | This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder to verify
   * @return { "verified" : "Returns true if account is successfully verified" }
   */
  function verifyAccount(Data storage self, address account) internal returns (bool verified) {
    require(getKYCApproval(self, account));
    require(getAccountStatus(self, account));
    return true;
  }


  /**
   * @notice Transfer an amount of currency token from msg.sender account to another specified account
   * @dev This function is called by an interface that is accessible directly to the account holder
   * @dev | This method has an `internal` view
   * @dev | This method uses `forceTransfer()` low-level api
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param to Ethereum address of account to send currency amount to
   * @param amount Value of currency to transfer
   * @param data Arbitrary bytes data to include with the transaction
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function transfer(Data storage self, string currency, address to, uint amount, bytes data) internal returns (bool success) {
    require(address(to) != 0x0);

    address feeContract = getFeeContract(self, address(this));
    uint fees = calculateFees(self, feeContract, amount);

    require(setAccountSpendingAmount(self, msg.sender, getFxUSDAmount(self, currency, amount)));
    require(forceTransfer(self, currency, msg.sender, to, amount, data));
    /// @dev "0x547846656573" == "TxFees"
    require(forceTransfer(self, currency, msg.sender, feeContract, fees, "0x547846656573"));

    return true;
  }

  /**
   * @notice Transfer an amount of currency token from account to another specified account via an approved spender account
   * @dev This function is called by an interface that is accessible directly to the account spender
   * @dev | This method has an `internal` view
   * @dev | Transactions will fail if the spending amount exceeds the daily limit
   * @dev | This method uses `forceTransfer()` low-level api
   * @dev | This method implements ERC20 transferFrom() method with approved spender behavior
   * @dev | msg.sender == spender; `updateAllowance()` reduces approved limit for account spender
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param from Ethereum address of account to send currency amount from
   * @param to Ethereum address of account to send currency amount to
   * @param amount Value of currency to transfer
   * @param data Arbitrary bytes data to include with the transaction
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function transferFrom(Data storage self, string currency, address from, address to, uint amount, bytes data) internal returns (bool success) {
    require(address(to) != 0x0);

    address feeContract = getFeeContract(self, address(this));
    uint fees = calculateFees(self, feeContract, amount);

    /// @dev NOTE: This transaction will fail if the spending amount exceeds the daily limit
    require(setAccountSpendingAmount(self, from, getFxUSDAmount(self, currency, amount)));

    /// @dev Attempt to transfer the amount
    require(forceTransfer(self, currency, from, to, amount, data));

    /// @dev "0x547846656573" == "TxFees"
    require(forceTransfer(self, currency, from, feeContract, fees, "0x547846656573"));

    /// @dev Attempt to update the spender allowance
    require(updateAllowance(self, currency, from, amount));

    return true;
  }

  /**
   * @notice Low-level transfer method
   * @dev | This method has an `internal` view
   * @dev | This method does not include fees or approved allowances.
   * @dev | This method is only for authorized interfaces to use (e.g. TokenIOFX)
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param from Ethereum address of account to send currency amount from
   * @param to Ethereum address of account to send currency amount to
   * @param amount Value of currency to transfer
   * @param data Arbitrary bytes data to include with the transaction
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function forceTransfer(Data storage self, string currency, address from, address to, uint amount, bytes data) internal returns (bool success) {
    require(address(to) != 0x0);

    bytes32 id_a = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, from)));
    bytes32 id_b = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, to)));

    require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).sub(amount)));
    require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).add(amount)));

    emit LogTransfer(currency, from, to, amount, data);

    return true;
  }

  /**
   * @notice Low-level method to update spender allowance for account
   * @dev | This method is called inside the `transferFrom()` method
   * @dev | msg.sender == spender address
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param account Ethereum address of account holder
   * @param amount Value to reduce allowance by (i.e. the amount spent)
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function updateAllowance(Data storage self, string currency, address account, uint amount) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.allowance', currency, getForwardedAccount(self, account), getForwardedAccount(self, msg.sender)));
    require(self.Storage.setUint(id, self.Storage.getUint(id).sub(amount)));
    return true;
  }

  /**
   * @notice Low-level method to set the allowance for a spender
   * @dev | This method is called inside the `approve()` ERC20 method
   * @dev | msg.sender == account holder
   * @param self Internal storage proxying TokenIOStorage contract
   * @param spender Ethereum address of account spender
   * @param amount Value to set for spender allowance
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function approveAllowance(Data storage self, address spender, uint amount) internal returns (bool success) {
    string memory currency = getTokenSymbol(self, address(this));

    bytes32 id_a = keccak256(abi.encodePacked('token.allowance', currency, getForwardedAccount(self, msg.sender), getForwardedAccount(self, spender)));
    bytes32 id_b = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, msg.sender)));

    require(self.Storage.getUint(id_a) == 0 || amount == 0);
    require(self.Storage.getUint(id_b) >= amount);
    require(self.Storage.setUint(id_a, amount));

    emit LogApproval(msg.sender, spender, amount);

    return true;
  }

  /**
   * @notice Deposit an amount of currency into the Ethereum account holder
   * @dev | The total supply of the token increases only when new funds are deposited 1:1
   * @dev | This method should only be called by authorized issuer firms
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param account Ethereum address of account holder to deposit funds for
   * @param amount Value of currency to deposit for account
   * @param issuerFirm Name of the issuing firm authorizing the deposit
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function deposit(Data storage self, string currency, address account, uint amount, string issuerFirm) internal returns (bool success) {
    bytes32 id_a = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, account)));
    bytes32 id_b = keccak256(abi.encodePacked('token.issued', currency, issuerFirm));
    bytes32 id_c = keccak256(abi.encodePacked('token.supply', currency));


    require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).add(amount)));
    require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).add(amount)));
    require(self.Storage.setUint(id_c, self.Storage.getUint(id_c).add(amount)));

    emit LogDeposit(currency, account, amount, issuerFirm);

    return true;

  }

  /**
   * @notice Withdraw an amount of currency from the Ethereum account holder
   * @dev | The total supply of the token decreases only when new funds are withdrawn 1:1
   * @dev | This method should only be called by authorized issuer firms
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param account Ethereum address of account holder to deposit funds for
   * @param amount Value of currency to withdraw for account
   * @param issuerFirm Name of the issuing firm authorizing the withdraw
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function withdraw(Data storage self, string currency, address account, uint amount, string issuerFirm) internal returns (bool success) {
    bytes32 id_a = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, account)));
    bytes32 id_b = keccak256(abi.encodePacked('token.issued', currency, issuerFirm)); // possible for issuer to go negative
    bytes32 id_c = keccak256(abi.encodePacked('token.supply', currency));

    require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).sub(amount)));
    require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).sub(amount)));
    require(self.Storage.setUint(id_c, self.Storage.getUint(id_c).sub(amount)));

    emit LogWithdraw(currency, account, amount, issuerFirm);

    return true;

  }

  /**
   * @notice Method for setting a registered issuer firm
   * @dev | Only Token, Inc. and other authorized institutions may set a registered firm
   * @dev | The TokenIOAuthority.sol interface wraps this method
   * @dev | If the registered firm is unapproved; all authorized addresses of that firm will also be unapproved
   * @param self Internal storage proxying TokenIOStorage contract
   * @param issuerFirm Name of the firm to be registered
   * @param approved Approval status to set for the firm (true/false)
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function setRegisteredFirm(Data storage self, string issuerFirm, bool approved) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('registered.firm', issuerFirm));
    require(self.Storage.setBool(id, approved));
    return true;
  }

  /**
   * @notice Method for setting a registered issuer firm authority
   * @dev | Only Token, Inc. and other approved institutions may set a registered firm
   * @dev | The TokenIOAuthority.sol interface wraps this method
   * @dev | Authority can only be set for a registered issuer firm
   * @param self Internal storage proxying TokenIOStorage contract
   * @param issuerFirm Name of the firm to be registered to authority
   * @param authorityAddress Ethereum address of the firm authority to be approved
   * @param approved Approval status to set for the firm authority (true/false)
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function setRegisteredAuthority(Data storage self, string issuerFirm, address authorityAddress, bool approved) internal returns (bool success) {
    require(isRegisteredFirm(self, issuerFirm));
    bytes32 id_a = keccak256(abi.encodePacked('registered.authority', issuerFirm, authorityAddress));
    bytes32 id_b = keccak256(abi.encodePacked('registered.authority.firm', authorityAddress));

    require(self.Storage.setBool(id_a, approved));
    require(self.Storage.setString(id_b, issuerFirm));

    return true;
  }

  /**
   * @notice Get the issuer firm registered to the authority Ethereum address
   * @dev | Only one firm can be registered per authority
   * @param self Internal storage proxying TokenIOStorage contract
   * @param authorityAddress Ethereum address of the firm authority to query
   * @return { "issuerFirm" : "Name of the firm registered to authority" }
   */
  function getFirmFromAuthority(Data storage self, address authorityAddress) internal view returns (string issuerFirm) {
    bytes32 id = keccak256(abi.encodePacked('registered.authority.firm', getForwardedAccount(self, authorityAddress)));
    return self.Storage.getString(id);
  }

  /**
   * @notice Return the boolean (true/false) registration status for an issuer firm
   * @param self Internal storage proxying TokenIOStorage contract
   * @param issuerFirm Name of the issuer firm
   * @return { "registered" : "Return if the issuer firm has been registered" }
   */
  function isRegisteredFirm(Data storage self, string issuerFirm) internal view returns (bool registered) {
    bytes32 id = keccak256(abi.encodePacked('registered.firm', issuerFirm));
    return self.Storage.getBool(id);
  }

  /**
   * @notice Return the boolean (true/false) status if an authority is registered to an issuer firm
   * @param self Internal storage proxying TokenIOStorage contract
   * @param issuerFirm Name of the issuer firm
   * @param authorityAddress Ethereum address of the firm authority to query
   * @return { "registered" : "Return if the authority is registered with the issuer firm" }
   */
  function isRegisteredToFirm(Data storage self, string issuerFirm, address authorityAddress) internal view returns (bool registered) {
    bytes32 id = keccak256(abi.encodePacked('registered.authority', issuerFirm, getForwardedAccount(self, authorityAddress)));
    return self.Storage.getBool(id);
  }

  /**
   * @notice Return if an authority address is registered
   * @dev | This also checks the status of the registered issuer firm
   * @param self Internal storage proxying TokenIOStorage contract
   * @param authorityAddress Ethereum address of the firm authority to query
   * @return { "registered" : "Return if the authority is registered" }
   */
  function isRegisteredAuthority(Data storage self, address authorityAddress) internal view returns (bool registered) {
    bytes32 id = keccak256(abi.encodePacked('registered.authority', getFirmFromAuthority(self, getForwardedAccount(self, authorityAddress)), getForwardedAccount(self, authorityAddress)));
    return self.Storage.getBool(id);
  }

  /**
   * @notice Return boolean transaction status if the transaction has been used
   * @param self Internal storage proxying TokenIOStorage contract
   * @param txHash keccak256 ABI tightly packed encoded hash digest of tx params
   * @return {"txStatus": "Returns true if the tx hash has already been set using `setTxStatus()` method"}
   */
  function getTxStatus(Data storage self, bytes32 txHash) internal view returns (bool txStatus) {
    bytes32 id = keccak256(abi.encodePacked('tx.status', txHash));
    return self.Storage.getBool(id);
  }

  /**
   * @notice Set transaction status if the transaction has been used
   * @param self Internal storage proxying TokenIOStorage contract
   * @param txHash keccak256 ABI tightly packed encoded hash digest of tx params
   * @return { "success" : "Return true if successfully called from another contract" }
   */
  function setTxStatus(Data storage self, bytes32 txHash) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('tx.status', txHash));
    require(self.Storage.setBool(id, true));
    return true;
  }

  /**
   * @notice Accepts a signed fx request to swap currency pairs at a given amount;
   * @dev | This method can be called directly between peers
   * @dev | This method does not take transaction fees from the swap
   * @param self Internal storage proxying TokenIOStorage contract
   * @param  requester address Requester is the orginator of the offer and must
   * match the signature of the payload submitted by the fulfiller
   * @param  symbolA    Symbol of the currency desired
   * @param  symbolB    Symbol of the currency offered
   * @param  valueA     Amount of the currency desired
   * @param  valueB     Amount of the currency offered
   * @param  sigV       Ethereum secp256k1 signature V value; used by ecrecover()
   * @param  sigR       Ethereum secp256k1 signature R value; used by ecrecover()
   * @param  sigS       Ethereum secp256k1 signature S value; used by ecrecover()
   * @param  expiration Expiration of the offer; Offer is good until expired
   * @return {"success" : "Returns true if successfully called from another contract"}
   */
  function execSwap(
    Data storage self,
    address requester,
    string symbolA,
    string symbolB,
    uint valueA,
    uint valueB,
    uint8 sigV,
    bytes32 sigR,
    bytes32 sigS,
    uint expiration
  ) internal returns (bool success) {

    bytes32 fxTxHash = keccak256(abi.encodePacked(requester, symbolA, symbolB, valueA, valueB, expiration));
    require(verifyAccounts(self, msg.sender, requester));

    /// @dev Ensure transaction has not yet been used;
    require(!getTxStatus(self, fxTxHash));

    /// @dev Immediately set this transaction to be confirmed before updating any params;
    require(setTxStatus(self, fxTxHash));

    /// @dev Ensure contract has not yet expired;
    require(expiration >= now);

    /// @dev Recover the address of the signature from the hashed digest;
    /// @dev Ensure it equals the requester's address
    require(ecrecover(fxTxHash, sigV, sigR, sigS) == requester);

    /// @dev Transfer funds from each account to another.
    require(forceTransfer(self, symbolA, msg.sender, requester, valueA, "0x0"));
    require(forceTransfer(self, symbolB, requester, msg.sender, valueB, "0x0"));

    emit LogFxSwap(symbolA, symbolB, valueA, valueB, expiration, fxTxHash);

    return true;
  }

  /**
   * @notice Deprecate a contract interface
   * @dev | This is a low-level method to deprecate a contract interface.
   * @dev | This is useful if the interface needs to be updated or becomes out of date
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Ethereum address of the contract interface
   * @return {"success" : "Returns true if successfully called from another contract"}
   */
  function setDeprecatedContract(Data storage self, address contractAddress) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('depcrecated', contractAddress));
    require(self.Storage.setBool(id, true));
    return true;
  }

  /**
   * @notice Return the deprecation status of a contract
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Ethereum address of the contract interface
   * @return {"status" : "Return deprecation status (true/false) of the contract interface"}
   */
  function isContractDeprecated(Data storage self, address contractAddress) internal view returns (bool status) {
    bytes32 id = keccak256(abi.encodePacked('depcrecated', contractAddress));
    return self.Storage.getBool(id);
  }

  /**
   * @notice Set the Account Spending Period Limit as UNIX timestamp
   * @dev | Each account has it's own daily spending limit
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of the account holder
   * @param period Unix timestamp of the spending period
   * @return {"success" : "Returns true is successfully called from a contract"}
   */
  function setAccountSpendingPeriod(Data storage self, address account, uint period) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('limit.spending.period', account));
    require(self.Storage.setUint(id, period));
    return true;
  }

  /**
   * @notice Get the Account Spending Period Limit as UNIX timestamp
   * @dev | Each account has it's own daily spending limit
   * @dev | If the current spending period has expired, it will be set upon next `transfer()`
   * or `transferFrom()` request
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of the account holder
   * @return {"period" : "Returns Unix timestamp of the current spending period"}
   */
  function getAccountSpendingPeriod(Data storage self, address account) internal view returns (uint period) {
    bytes32 id = keccak256(abi.encodePacked('limit.spending.period', account));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Set the account spending limit amount
   * @dev | Each account has it's own daily spending limit
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of the account holder
   * @param limit Spending limit amount
   * @return {"success" : "Returns true is successfully called from a contract"}
   */
  function setAccountSpendingLimit(Data storage self, address account, uint limit) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('account.spending.limit', account));
    require(self.Storage.setUint(id, limit));
    return true;
  }

  /**
   * @notice Get the account spending limit amount
   * @dev | Each account has it's own daily spending limit
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of the account holder
   * @return {"limit" : "Returns the account spending limit amount"}
   */
  function getAccountSpendingLimit(Data storage self, address account) internal view returns (uint limit) {
    bytes32 id = keccak256(abi.encodePacked('account.spending.limit', account));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Set the account spending amount for the daily period
   * @dev | Each account has it's own daily spending limit
   * @dev | This transaction will throw if the new spending amount is greater than the limit
   * @dev | This method is called in the `transfer()` and `transferFrom()` methods
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of the account holder
   * @param amount Set the amount spent for the daily period
   * @return {"success" : "Returns true is successfully called from a contract"}
   */
  function setAccountSpendingAmount(Data storage self, address account, uint amount) internal returns (bool success) {

    /// @dev NOTE: Always ensure the period is current when checking the daily spend limit
    require(updateAccountSpendingPeriod(self, account));
    uint updatedAmount = getAccountSpendingAmount(self, account).add(amount);

    /// @dev Ensure the spend limit is greater than the amount spend for the period
    require(getAccountSpendingLimit(self, account) >= updatedAmount);

    /// @dev Update the spending period amount if within limit
    bytes32 id = keccak256(abi.encodePacked('account.spending.amount', account, getAccountSpendingPeriod(self, account)));
    require(self.Storage.setUint(id, updatedAmount));
    return true;
  }

  /**
   * @notice Low-level API to ensure the account spending period is always current
   * @dev | This method is internally called by `setAccountSpendingAmount()` to ensure
   * spending period is always the most current daily period.
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of the account holder
   * @return {"success" : "Returns true is successfully called from a contract"}
   */
  function updateAccountSpendingPeriod(Data storage self, address account) internal returns (bool success) {
    uint begDate = getAccountSpendingPeriod(self, account);
    if (begDate > now) {
      return true;
    } else {
      uint duration = 86400; // 86400 Seconds in a Day
      require(setAccountSpendingPeriod(self, account, begDate.add(((now.sub(begDate)).div(duration).add(1)).mul(duration))));
      return true;
    }
  }

  /**
   * @notice Return the amount spent during the current period
   * @dev | Each account has it's own daily spending limit
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of the account holder
   * @return {"amount" : "Returns the amount spent by the account during the current period"}
   */
  function getAccountSpendingAmount(Data storage self, address account) internal view returns (uint amount) {
    bytes32 id = keccak256(abi.encodePacked('account.spending.amount', account, getAccountSpendingPeriod(self, account)));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Return the amount remaining during the current period
   * @dev | Each account has it's own daily spending limit
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of the account holder
   * @return {"amount" : "Returns the amount remaining by the account during the current period"}
   */
  function getAccountSpendingRemaining(Data storage self, address account) internal view returns (uint remainingLimit) {
    return getAccountSpendingLimit(self, account).sub(getAccountSpendingAmount(self, account));
  }

  /**
   * @notice Set the foreign currency exchange rate to USD in basis points
   * @dev | This value should always be relative to USD pair; e.g. JPY/USD, GBP/USD, etc.
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency The TokenIO currency symbol (e.g. USDx, JPYx, GBPx)
   * @param bpsRate Basis point rate of foreign currency exchange rate to USD
   * @return { "success": "Returns true if successfully called from another contract"}
   */
  function setFxUSDBPSRate(Data storage self, string currency, uint bpsRate) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fx.usd.rate', currency));
    require(self.Storage.setUint(id, bpsRate));
    return true;
  }

  /**
   * @notice Return the foreign currency USD exchanged amount in basis points
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency The TokenIO currency symbol (e.g. USDx, JPYx, GBPx)
   * @return {"usdAmount" : "Returns the foreign currency amount in USD"}
   */
  function getFxUSDBPSRate(Data storage self, string currency) internal view returns (uint bpsRate) {
    bytes32 id = keccak256(abi.encodePacked('fx.usd.rate', currency));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Return the foreign currency USD exchanged amount
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency The TokenIO currency symbol (e.g. USDx, JPYx, GBPx)
   * @param fxAmount Amount of foreign currency to exchange into USD
   * @return {"amount" : "Returns the foreign currency amount in USD"}
   */
  function getFxUSDAmount(Data storage self, string currency, uint fxAmount) internal view returns (uint amount) {
    uint usdDecimals = getTokenDecimals(self, 'USDx');
    uint fxDecimals = getTokenDecimals(self, currency);
    /// @dev ensure decimal precision is normalized to USD decimals
    uint usdAmount = ((fxAmount.mul(getFxUSDBPSRate(self, currency)).div(10000)).mul(10**usdDecimals)).div(10**fxDecimals);
    return usdAmount;
  }


}
