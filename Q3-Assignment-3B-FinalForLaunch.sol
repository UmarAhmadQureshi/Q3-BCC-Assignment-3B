// SPDX-License-Identifier: MIT
// Deployed at https://ropsten.etherscan.io/tx/0x29886b3806784b65150aa6c0f201677637733d6495832cf4748f08d0b7f8f6d5
pragma solidity ^0.8.0;
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC20/ERC20.sol";

contract BuyableToken is IERC20{
   
    address public contractOwner;
   
    //mapping to keep balances
    mapping (address => uint256) private _balances;
   
    //the amount of tokens in existence
    uint256 private _totalSupply;
   
    //price of tokens
    uint256 public tokenPrice;
   
    uint256 public decimals;
    
    //releaseTime must be greater and in unix time format
    uint256 public releaseTime;
    
    //value of capped tokens
    uint256 private _cap;
   
    constructor(uint256 _price) {
        require(_price > 0, "Token price must be valid");
   
    decimals = 18;
    contractOwner = msg.sender;
    tokenPrice = _price;
       
    _totalSupply = 1000000 * (10 ** decimals);

    _balances[contractOwner] = _totalSupply;
    _cap = _totalSupply;
       
    }
   
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only contract owner allowed");
        _;
    }
    
    modifier timeLock() {
        require(block.timestamp >= releaseTime, "Token is locked, wait for releaseTime");
        _;
    }
    
    function totalSupply() external view override returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns(uint256) {
        return _balances[account];
    }
   

    function transfer(address recipient, uint256 amount) external override timeLock() returns(bool) {
        address sender = msg.sender;
        
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[sender] > amount);
        
        _balances[sender] -= amount; 
        
        _balances[recipient] += amount;
        
        return true;
    }
   
     function allowance(address tokenOwner, address spender) external view override returns(uint256) {
        return  0;
    }

    function approve(address spender, uint256 amount) external override returns(bool) {
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns(bool) {
        return true;
    }
   
   
    function ModifyPrice(uint256 _price) public onlyOwner() returns(bool) {
        require(_price > 0, "Token price must be valid");
       
        tokenPrice = _price;
       
        return true;
    }
   
   
    function buyToken() public payable returns(bool) {
        address _recipient = msg.sender;
   
        require(_recipient != address(0), "Transfer to the burn address");
        require(msg.value > 0, "Amount must be valid");
   
        uint256 _numberOfWeiTokens = (msg.value ) * tokenPrice;
       
        require(_numberOfWeiTokens > 0, "Number of tokens must be valid");
        require(_balances[contractOwner] >= _numberOfWeiTokens, "Insufficient funds");
   
        _balances[contractOwner] -= _numberOfWeiTokens;
   
        _balances[_recipient] += _numberOfWeiTokens;
       
        payable(contractOwner).transfer(msg.value);
       
        return true;
    }
   
    fallback() external payable {
        buyToken();
    }
    
    receive() external payable {
        buyToken();
    }
    
    function Mint(uint256 amount) public onlyOwner() returns(bool) {
        require(amount > 0, "Amount should be valid");
        require(((_totalSupply + amount) <= _cap), "Total Supply has exceeded the capped limit");
        
        _balances[contractOwner] += amount;
        _totalSupply += amount;
        
        return true;
    } 
    
    function setCap(uint256 _capValue) public onlyOwner() returns (bool) {
        require(_capValue > 0, "Amount should be valid");
        
        _cap = _capValue;
        
        return true;
    }
    
    function getCap() public view returns (uint256) {
        return _cap;
    }
    
    function setReleaseTime(uint _releaseTime_UNIXFormat) public onlyOwner() returns(bool) {
        require(_releaseTime_UNIXFormat > block.timestamp, "ReleaseTime must be valid");
        releaseTime = _releaseTime_UNIXFormat;
        
        return true;
    }
    
    function getReleaseTime() public onlyOwner() returns(uint) {
        // require(_releaseTime_UNIXFormat > block.timestamp, "ReleaseTime must be valid");
        // releaseTime = _releaseTime_UNIXFormat;
        
        return block.timestamp;
    }
}
