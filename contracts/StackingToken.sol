// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract StackingToken is ERC20, ERC721Holder, Ownable {

    using SafeMath for uint256;
    IERC721 public nft;
    
    uint256 public REWARD_RATE = (SafeMath.div(1, 2) * 10 ** decimals()) / 2 days;
    uint256 public TRANSFER_WHITELISTED = 1000*10**18 ;
    uint256 public TRANSFER_NONWHITELISTED = 500*10**18;

    constructor() ERC20("StackingToken", "MSK") {
        _mint(msg.sender, 100000*10**decimals());
    }

    mapping(address => uint) public totalTransfer; // total tokens transfered in ongoing day
    mapping(address => uint40) public lockTime; // time from where last day started
    mapping(address => bool) public whitelisted; // for holding whitelisted user
    mapping(uint256 => address) public tokenOwner; // stacked nft id with respective owner
    mapping(uint256 => uint256) public tokenStakedAt; // time at which nft was stacked

    //@note events for stacking unstacking and transfer
    event TransferTken(address indexed _to, uint256 amount);
    event StakeEvent(address indexed owner, uint256 indexed _id);
    event UnStakeEvent(address indexed owner, uint256 indexed _id);

    //@note sets the contract of which the nfts will be being stacked
    function setNFTContract(address _contract) external onlyOwner{
        nft = IERC721(_contract);
    }
    
    //@note sets limit for non whitelisted users
    function setLimitForNonWhitelisted(uint256 _amount) external {
        TRANSFER_NONWHITELISTED = _amount;
    }
    
    //@note sets limit for whitelisted users
    function setLimitForWhitelisted(uint256 _amount) external {
        TRANSFER_WHITELISTED = _amount;
    }
    
    //@note for whitelisting multiple addresses
    function batchWhitelist(address[] memory _users) external {
        uint size = _users.length;
        for(uint256 i=0; i< size; i++){
            address user = _users[i];
            whitelisted[user] = true;
        }
    }
    
    //@note overriden transfer function with transfer limit
    function transfer(address to, uint256 amount) public override(ERC20) returns (bool){
        if (checkTimit(msg.sender)< 1 days) {
            totalTransfer[msg.sender] = 0;
            lockTime[msg.sender] = uint40(block.timestamp);
        }
        if (whitelisted[msg.sender] == true){
            require(totalTransfer[msg.sender]+ amount <=TRANSFER_WHITELISTED, "limit reached");
            totalTransfer[msg.sender] = totalTransfer[msg.sender] + amount;
            super.transfer(to, amount);
            emit TransferTken(to, amount);
            return true;
        } else 
        {
            require(totalTransfer[msg.sender]+ amount <=TRANSFER_NONWHITELISTED, "limit reached");
            totalTransfer[msg.sender] = totalTransfer[msg.sender] + amount;
            super.transfer(to, amount);
            emit TransferTken(to, amount);
            return true;
        }
    }
    

    //@note checks the time remaining in ongoing day
    function checkTimit(address _user) internal view returns (uint40){
        return uint40(block.timestamp) - lockTime[_user];
    }
    

    //@note stackes the nft with given id for whoever the caller of this function is
    function stake(uint256 tokenId) external {
        require(nft.balanceOf(msg.sender)>0, "NFT not available");
        require(nft.ownerOf(tokenId) ==msg.sender,"You are not owner");
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        tokenOwner[tokenId] = msg.sender;
        tokenStakedAt[tokenId] = block.timestamp;
        emit StakeEvent(msg.sender, tokenId);
    }
    

    //@note unstackes and transfers the reward to the owner of nft
    function unstake(uint256 tokenId) external {
        require(tokenOwner[tokenId] == msg.sender, "You can't unstake");
        _mint(msg.sender, calculateTokens(tokenId)); 
        nft.transferFrom(address(this), msg.sender, tokenId);
        delete tokenOwner[tokenId];
        delete tokenStakedAt[tokenId];
        emit UnStakeEvent(msg.sender, tokenId);
    }
    
    //@note calculates the reward according to conditions imposed
    function calculateTokens(uint256 tokenId) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - tokenStakedAt[tokenId];
        uint256 totalReward =timeElapsed * REWARD_RATE;
        if(timeElapsed< 90 days){
            return totalReward;
        }
        else {
            return totalReward.div(2);
        }   
    }

}