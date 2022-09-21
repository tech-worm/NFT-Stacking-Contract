// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract RewardToken is ERC20, ERC721Holder, Ownable {

    using SafeMath for uint256;
    IERC721 public nft;
    bytes32 private _root;
    
    uint256 public REWARD_RATE = (SafeMath.div(1, 2) * 10 ** decimals()) / 2 days;
    uint256 public TRANSFER_WHITELISTED = 1000*10**18 ;
    uint256 public TRANSFER_NONWHITELISTED = 500*10**18;

    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 100000*10**decimals());
    }

    mapping(address => uint) public totalTransfer;
    mapping(uint256 => address) public tokenOwner;
    mapping(uint256 => uint256) public tokenStakedAt;
    
    //@note events for stacking unstacking and transfer
    event StakeEvent(address indexed owner, uint256 indexed _id);
    event UnStakeEvent(address indexed owner, uint256 indexed _id);

    function setNFTContract(address _contract) external onlyOwner{
        nft = IERC721(_contract);
    }


    function stake(uint256 tokenId, bytes32[] memory _proof) external {
        require(isWhiteListed(_proof, _root, getMarkleLeaf(msg.sender)), "Not Whitelisted");
        require(nft.balanceOf(msg.sender)>0, "NFT not available");
        require(nft.ownerOf(tokenId) ==msg.sender,"You are not owner");
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        tokenOwner[tokenId] = msg.sender;
        tokenStakedAt[tokenId] = block.timestamp;
        emit StakeEvent(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external {
        require(tokenOwner[tokenId] == msg.sender, "You can't unstake");
        _mint(msg.sender, calculateTokens(tokenId)); 
        nft.transferFrom(address(this), msg.sender, tokenId);
        delete tokenOwner[tokenId];
        delete tokenStakedAt[tokenId];
        emit UnStakeEvent(msg.sender, tokenId);
    }

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

    function setRoot(bytes32 root) public onlyOwner {
        _root = root;
    }

    function getMarkleLeaf(address _user) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_user));
    }

    function isWhiteListed(
    bytes32[] memory _prof,
    bytes32 _rot,
    bytes32 _leaf
    ) public pure returns (bool) {
        return MerkleProof.verify(_prof, _rot, _leaf);
   }


}