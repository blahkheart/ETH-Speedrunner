// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interface/IUnlockV11.sol";
import "./interface/IPublicLockV10.sol";
import "./DGToken.sol";


/**
  @title DreadGang NFT Contract
  @author Danny Thomx
  @notice Explain to an end user what this does
  @dev Explain to a developer any extra details
*/

// Change log
// - Charged 100 DGTokens for multiMinting
// - removed setMaxMintAmount function
// TODO
// require user to be Hustler or higher to use multimint
// require multiMint lock to be set only once

contract DreadGang is ERC721Enumerable, ERC721URIStorage, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  // uint256 public cost = 0.01 ether;
  DGToken dgToken;
  string baseURI;
  string public notRevealedUri;
  string public baseExtension = ".json";
  uint8 public maxMintAmount = 4;
  uint8 public baseLevelUpFee = 40; // @notice Determines the % of fee paid to level up (charged in DGTokens)
  uint32 public baseLevelNoob = 10; // @notice Determines the base level for the Noob class
  uint32 public baseLevelHustler = 40; // @notice Determines the base level for the Hustler class
  uint32 public baseLevelOG = 100; // @notice Deternmines the base level for the OG class
  uint32 public baseLevelUpReward = 1; // @notice The number which is multiplied with the current level to determine the level up reward (in DGTokens)
  uint256 public gatePassNoob = 0.001 ether; // @notice Fee for creating levels for class Noob (charged in ETH)
  uint256 public gatePassHustler = 0.01 ether; // @notice Fee for creating levels for class Hustler (charged in ETH)
  uint256 public gatePassOG = 0.1 ether; // @notice Fee for creating levels for class OG (charged in ETH)
  uint256 public maxSupply = 10000;
  bool public paused = false;
  bool public revealed = false;
  bool initialRevenue = false;
  address public vendor;
  address dev = 0xCA7632327567796e51920F6b16373e92c7823854;

  // uint256 _optionId;
  // uint256 dues;
  Counters.Counter private _tokenIdCounter;

 
  // IUnlockV11 public unlock;
  IPublicLock public publicLock;
  bool public isPublicLockAddressSet = false; // tracks whether a lock address has been set.
  IPublicLock public mintLock;
  IPublicLock public multiMintLock;
  bool isMultiMintLockAddressSet = false;

  struct LevelUnlockData {
    address lockAddress;
    bool init;
    uint minTargetLevel;
    address creator;
  }
  mapping(address => mapping(uint256 => uint256)) level;
  mapping(address => bool) private squadMember;
  mapping(address => mapping(address => bool))private multiMintKeyUsed;
  mapping(address => bool) allLevels;
  mapping(address => LevelUnlockData) public levelData;
  mapping(address => mapping(uint => bool)) unlockedLevels;

// todo: edit events
  event LevelUp(address levelLock, uint256 indexed tokenId, uint256 indexed newLevel);
  event CreateLevel(address indexed levelLock, uint256 indexed minTargetLevel, address creator);

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri,
    IPublicLock _mintLockAddress,
    DGToken _dgToken
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
    _setMintLockAddr(_mintLockAddress);
    dgToken = _dgToken;
  }

  modifier onlyMember {
    if(msg.sender != owner()){
      require(squadMember[msg.sender] == true, "members only");
    }
    _;
  }

  //@Notice Sets the level threshold which determines the current class of the NFT
  function setBaseLevelRate(uint32 _targetBaseRate, uint32 _newBaseRate)public onlyOwner {
    if(_targetBaseRate == baseLevelNoob)
      baseLevelNoob = _newBaseRate;
    else if(_targetBaseRate == baseLevelHustler)
      baseLevelHustler = _newBaseRate;
    else if(_targetBaseRate == baseLevelOG)
      baseLevelOG = _newBaseRate;
  }

  //@Notice Sets the fee charged for creating a level at the current class of the NFT
  function setBaseGatePassRate(uint32 _targetBaseRate, uint32 _newBaseRate)public onlyOwner {
    if(_targetBaseRate == gatePassNoob)
      gatePassNoob = _newBaseRate;
    else if(_targetBaseRate == gatePassHustler)
      gatePassHustler = _newBaseRate;
    else if(_targetBaseRate == gatePassOG)
      gatePassOG = _newBaseRate;
  }

  //@Notice Sets the DGToken reward multiplier for level ups
  function setBaseLevelUpReward(uint32 _newBaseLevelUpReward)public onlyOwner {
    baseLevelUpReward = _newBaseLevelUpReward;
  }

  //@Notice Sets the base % DGTokens charged against the current level for leveling up the NFT
  function setBaseLevelUpFee(uint8 _newBaseLevelUpFee)public onlyOwner {
    baseLevelUpFee = _newBaseLevelUpFee;
  }

  //@Notice Sets DGTokens vendor address;
  function setVendorAddress(address _vendor)public onlyOwner {
    vendor = _vendor;
  }
    

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function _levelUp(address _account, uint256 _tokenId) private returns(uint) {
   uint256 currentLevel = level[_account][_tokenId];
   uint256 newLevel = currentLevel + 1;
   level[_account][_tokenId] = newLevel;
   return newLevel;
  }

// @Notice To get the level of an nft
  function getLevel(address _account, uint _tokenId) public view returns(uint){
    require(_exists(_tokenId), "Non existent token");
    return level[_account][_tokenId];
  } 

// @Notice Check if an address is a DreadGang member
  function isSquadMember(address _account) public view returns(bool){
    bool dadaG = squadMember[_account];
    return dadaG;
  } 

// @Notice To level up an nft
  function levelUp(IPublicLock _levelLock, uint _tokenId) public payable onlyMember returns(uint) {
    require(_exists(_tokenId), "Nonexistent token");
    IPublicLock levelLock =_levelLock;
    address levelLockAddress = address(levelLock);
    require(allLevels[levelLockAddress], "Nonexistent level");
    uint256 currentLevel = level[msg.sender][_tokenId];
    uint256 levelUpDues = currentLevel * baseLevelUpFee / 100;
    uint256 baseLevelUpRewardFee = _setOptionId(currentLevel);
      
    require(_hasValidKey(msg.sender, levelLock), "Invalid key");
    require(currentLevel >= levelData[levelLockAddress].minTargetLevel , "Meet the minimum level");
    require(currentLevel <= levelData[levelLockAddress].minTargetLevel + 5 , "Within 5 levels of min Target level");
    require(unlockedLevels[levelLockAddress][_tokenId] == false, "Already unlocked");

    if (msg.sender != owner()) {
      require(msg.sender != levelData[levelLockAddress].creator, "level created by you");
      // (bool _sent, ) = msg.sender.call{value: cost}("");
      // require(_sent, "Failed to send level Up fees");
    }
    if(baseLevelUpRewardFee != 3){
      (bool sent) = dgToken.transferFrom(msg.sender, address(this), levelUpDues);
      require(sent, "Insufficient DGTokens");
    }
    uint newLevel = _levelUp(msg.sender, _tokenId);
    unlockedLevels[levelLockAddress][_tokenId] = true;
    dgToken.mintToken(msg.sender, newLevel * baseLevelUpReward);

    emit LevelUp(levelLockAddress, _tokenId, newLevel);
    return newLevel;
  }


// @Notice To create a new level lock
  function createLevelUpLock(IPublicLock _levelLock, uint _minTargetLevel)public payable onlyMember {
    IPublicLock levelToUnlock = _levelLock;
    address levelToUnlockAddr = address(levelToUnlock);
    require(_minTargetLevel >= 0, "Number greater >= 0");
    require(_hasValidKey(msg.sender, levelToUnlock), "invalid key");
    require(allLevels[levelToUnlockAddr] == false, "Already created");
    uint duesOption = _setOptionId(_minTargetLevel);
    uint levelDuesOption;
    if(duesOption == 0){
      levelDuesOption = gatePassNoob;
    } else if (duesOption == 1){
      levelDuesOption = gatePassHustler;
    }else if (duesOption == 2){
      levelDuesOption = gatePassOG;
    }else {
      levelDuesOption = 0;
    }
    if(msg.sender != owner()) {
      require(msg.value >= levelDuesOption, "Insufficient dues");
      // require(payable(address(this)).send(cost), "Failed to transfer level Up fees");
    }

    allLevels[levelToUnlockAddr] = true;
    _setLevelUnLockData(levelToUnlockAddr, true, _minTargetLevel);
    emit CreateLevel(levelToUnlockAddr, _minTargetLevel, msg.sender);
  }

// @Notice set the level to unlock data
  function _setLevelUnLockData(address _levelToUnlockAddr, bool _init, uint _minTargetLevel) private {
    levelData[_levelToUnlockAddr] = LevelUnlockData(_levelToUnlockAddr, _init, _minTargetLevel, msg.sender);
  }

// @Notice select different options based on number input 
  function _setOptionId (uint _option) internal view returns(uint){
    uint8 _optionId;
    if(_option >= baseLevelNoob){
        _optionId = 0;
    } else if (_option >= baseLevelHustler) {
        _optionId = 1;
    } else if (_option >= baseLevelOG) {
        _optionId = 2;
    } else {
      _optionId = 3;
    }
    return _optionId;
  }

  // unlock protocol
  // @notice sets publicLock to a specific lock address which is used to create levels for DreadGang community
  function setPublicLockAddr (IPublicLock _publicLockAddress) external onlyOwner {
    publicLock = _publicLockAddress;
    isPublicLockAddressSet = true;
  }
  function _setMintLockAddr (IPublicLock _publicLockAddress) private onlyOwner{
    mintLock = _publicLockAddress;
  }
  function setMultiMintLockAddr (IPublicLock _multiMintLockAddress) external onlyOwner {
    multiMintLock = _multiMintLockAddress;
    isMultiMintLockAddressSet = true;
  }

  function _hasValidMintKey (address _account) internal view returns(bool) {
    bool isMember = mintLock.getHasValidKey(_account);
    return isMember;
  }

  function _hasValidMultiMintKey (address _account) internal view returns(bool) {
    bool hasKey = multiMintLock.getHasValidKey(_account);
    return hasKey;
  }

  function _hasValidKey (address _account, IPublicLock _publicLock) internal view returns(bool) {
    IPublicLock pubLock = _publicLock;
    bool hasKey = pubLock.getHasValidKey(_account);
    return hasKey;
  }

  // @notice Mint single nft
  function mintItem(address to, string memory uri) public returns (uint256) {
    uint256 supply = totalSupply();
    require(!paused, "Minting paused");
    require(supply < maxSupply, "Minting over");
    require(squadMember[msg.sender] == false, "Already member");
    require(_hasValidMintKey(msg.sender) == true, "only members");

    if (msg.sender != owner()) {
      squadMember[msg.sender] = true;
    }
    _tokenIdCounter.increment();
    uint256 tokenId = _tokenIdCounter.current();
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, uri);
    return tokenId;
  }


// @notice Mint multiple nfts 
  function multiMint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused, "Contract paused");
    require(_mintAmount > 1, "Enter amount greater than 1");
    require(_mintAmount <= maxMintAmount, "Amount greater than allowed limit");
    require(supply + _mintAmount <= maxSupply, "Minting over");
    require(multiMintKeyUsed[address(multiMintLock)][msg.sender] == false, "You have already used this Multi mint key");


    if (msg.sender != owner()) {
      require(squadMember[msg.sender] == true, "Only members can mint a squad");
      require(_hasValidMultiMintKey(msg.sender), "Need valid multi mint key to mint ");
      (bool sent) = dgToken.transferFrom(msg.sender, address(this), 100);
      require(sent, "Insufficient DGTokens");
      multiMintKeyUsed[address(multiMintLock)][msg.sender] = true;
      
    }
   
    for (uint256 i = 1; i <= _mintAmount; i++) {
      _tokenIdCounter.increment();
      uint256 tokenId = _tokenIdCounter.current();
      _safeMint(msg.sender, tokenId);
    }
  }

// @Dev Get the number of nfts by tokenIds owner has
  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override(ERC721, ERC721URIStorage)
    returns (string memory)
  {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  // @notice Display hidden nft URI
  function reveal() public onlyOwner {
    revealed = true;
  }

  // function setmaxMintAmount(uint8 _newmaxMintAmount) public onlyOwner {
  //   maxMintAmount = _newmaxMintAmount;
  // }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
  function withdraw() public payable onlyOwner {
    address hashlips = 0x943590A42C27D08e3744202c4Ae5eD55c2dE240D; 
    address buidlguidl = 0x97843608a00e2bbc75ab0C1911387E002565DEDE;
    
    // This will pay HashLips 3% of the initial sale.
    // You can remove this if you want, or keep it in to support HashLips and his channel.
    // =============================================================================
    if (!initialRevenue){
      (bool hl, ) = payable(hashlips).call{value: address(this).balance * 3 / 100}("");
      require(hl);

      (bool pg, ) = payable(buidlguidl).call{value: address(this).balance * 3 / 100}("");
      require(pg);

      (bool v, ) = payable(vendor).call{value: address(this).balance * 44 / 100}("");
      require(v);

      // This will payout the dev 50% of the initial Revenue.
      (bool d, ) = payable(dev).call{value: address(this).balance}("");
      require(d);

      initialRevenue = true;
    } else {
      (bool v, ) = payable(vendor).call{value: address(this).balance * 70 / 100}("");
      require(v);

      (bool d, ) = payable(dev).call{value: address(this).balance * 10 / 100}("");
      require(d);

      (bool o, ) = payable(owner()).call{value: address(this).balance}("");
      require(o);

    }
    // =============================================================================
    
    // =============================================================================
  }
  function withdrawToken() public payable onlyOwner {
    uint256 dgTokenBalance = dgToken.balanceOf(address(this));
    if (!initialRevenue){
      dgToken.transfer(vendor, dgTokenBalance * 20 / 100 );
      dgToken.transfer(dev, dgTokenBalance * 20 / 100 );
      (bool dg) = dgToken.transfer(owner(), dgTokenBalance);
      require(dg);
      initialRevenue = true;
    } else {
      dgToken.transfer(vendor, dgTokenBalance * 20 / 100);
      dgToken.transfer(dev, dgTokenBalance * 10 / 100 );
      dgToken.transfer(owner(), dgTokenBalance);
    }
  }

  // The following functions are overrides required by Solidity.
  function _beforeTokenTransfer(
      address from,
      address to,
      uint256 tokenId
  ) internal override(ERC721, ERC721Enumerable) {
      super._beforeTokenTransfer(from, to, tokenId);
  }

  function _burn(uint256 tokenId)
      internal
      override(ERC721, ERC721URIStorage)
  {
      super._burn(tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
      public
      view
      override(ERC721, ERC721Enumerable)
      returns (bool)
  {
      return super.supportsInterface(interfaceId);
  }

}