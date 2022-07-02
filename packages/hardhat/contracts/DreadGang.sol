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
 * @title Dada G
 * Creature - a contract for my non-fungible creatures.
 */
contract DreadGang is ERC721Enumerable, ERC721URIStorage, Ownable {

  using Strings for uint256;
  using Counters for Counters.Counter;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.005 ether;
  uint256 public gatePassNoob = 0.01 ether;
  uint256 public gatePassHustler = 0.05 ether;
  uint256 public gatePassOG = 0.1 ether;
  uint256 public maxSupply = 10000;
  uint256 public maxMintAmount = 6;
  bool public paused = false;
  bool public revealed = false;
  string public notRevealedUri;
  uint256 _optionId;
  Counters.Counter private _tokenIdCounter;
  uint256 dues = 100;

  IPublicLock public publicLock;
  IUnlockV11 public unlock;
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
  mapping(address => LevelUnlockData) levelData;
  mapping(address => mapping(uint => bool)) unlockedLevels;
  DGToken public dgToken;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri,
    IPublicLock _mintLockAddress,
    address _dgTokenAddr
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
    _setMintLockAddr(_mintLockAddress);
    dgToken = DGToken(_dgTokenAddr);
  }

  modifier onlyMember {
    if(msg.sender != owner()){
      require(squadMember[msg.sender] == true, "Only DreadGang members can access this functionality");
    }
    _;
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function _levelUp(address _account, uint256 _tokenId) internal returns(uint) {
   uint256 currentLevel = level[_account][_tokenId];
   uint256 newLevel = currentLevel + 1;
   level[_account][_tokenId] = newLevel;
   return newLevel;
  }

  // @dev To get the level of an nft
  function getLevel(address _account, uint _tokenId) public view returns(uint){
    require(_exists(_tokenId), "Query for non existent token");
    return level[_account][_tokenId];
  } 

// @dev To level up an nft
  function levelUp(IPublicLock _levelLock, uint _tokenId) public payable onlyMember returns(uint) {
    require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
    IPublicLock levelLock =_levelLock;
    address levelLockAddress = address(levelLock);
    require(allLevels[levelLockAddress], "This level does not exist");
    uint currentLevel = level[msg.sender][_tokenId];
    
    require(_hasValidKey(msg.sender, levelLock), "You do not have a valid key to unlock this level"); // Prevent level creator from using their lock to level up. To level up u must use others' level up keys.
    require(currentLevel >= levelData[levelLockAddress].minTargetLevel , "You do not meet the minimum level to use this key");
    require(unlockedLevels[levelLockAddress][_tokenId] == false, "Already unlocked this level");

    if (msg.sender != owner()) {
      require(msg.sender != levelData[levelLockAddress].creator, "Cannot level up with level created by you");
      (bool _sent, ) = msg.sender.call{value: cost}("");
      require(_sent, "Failed to send level Up fees");
    }
    uint newLevel = _levelUp(msg.sender, _tokenId);
    unlockedLevels[levelLockAddress][_tokenId] = true;

    return newLevel;
  }


// @dev To create a new level lock
  function createLevelUpLock(IPublicLock _levelLock, uint _minTargetLevel)public payable onlyMember {
    IPublicLock levelToUnlock = _levelLock;
    address levelToUnlockAddr =address(levelToUnlock);
    require(_minTargetLevel >= 0, "Enter valid number greater than or equal to 0");
    require(_hasValidKey(msg.sender, levelToUnlock), "You do not have a valid key for this lock");
    require(allLevels[levelToUnlockAddr] == false, "This level has already been created");
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
      require(msg.value >= levelDuesOption, "Insufficient dues to execute this function");
      // require(payable(address(this)).send(cost), "Failed to transfer level Up fees");
    }

    allLevels[levelToUnlockAddr] = true;
    _setLevelUnLockData(levelToUnlockAddr, true, _minTargetLevel);
  }

  function _setLevelUnLockData(address _levelToUnlockAddr, bool _init, uint _minTargetLevel) internal {
    levelData[_levelToUnlockAddr] = LevelUnlockData(_levelToUnlockAddr, _init, _minTargetLevel, msg.sender);
  }

  function _setOptionId (uint _option) internal returns(uint){
    if(_option >= 10){
        _optionId = 0;
    } else if (_option >= 40) {
        _optionId = 1;
    } else if (_option >= 100) {
        _optionId = 2;
    } else {
      _optionId = 3;
    }
    return _optionId;
  }

  // unlock protocol
  function _setPublicLockAddr (IPublicLock _publicLockAddress) private onlyOwner {
    publicLock = _publicLockAddress;
    isPublicLockAddressSet = true;
  }
  function _setMintLockAddr (IPublicLock _publicLockAddress) internal {
    mintLock = _publicLockAddress;
  }
  function _setMultiMintLockAddr (IPublicLock _multiMintLockAddress) private onlyOwner {
    multiMintLock = _multiMintLockAddress;
    isMultiMintLockAddressSet = true;
  }

  function _hasValidMintKey (address _account) private view returns(bool) {
    bool isMember = mintLock.getHasValidKey(_account);
    return isMember;
  }

  function _hasValidMultiMintKey (address _account) private view returns(bool) {
    bool hasKey = multiMintLock.getHasValidKey(_account);
    return hasKey;
  }

  function _hasValidKey (address _account, IPublicLock _publicLock) private view returns(bool) {
    IPublicLock pubLock = _publicLock;
    bool hasKey = pubLock.getHasValidKey(_account);
    return hasKey;
  }

  // public
  // Mint single nft
  function mintItem(address to, string memory uri) public returns (uint256) {
    uint256 supply = totalSupply();
    require(!paused, "Minting is on pause.");
    require(supply < maxSupply, "Minting over");
    require(squadMember[msg.sender] == false, "Already part of the squad");

    if (msg.sender != owner()) {
      require(_hasValidMintKey(msg.sender) == true, "only members can mint");
      squadMember[msg.sender] = true;
    }
    _tokenIdCounter.increment();
    uint256 tokenId = _tokenIdCounter.current();
      _safeMint(to, tokenId);
      _setTokenURI(tokenId, uri);
    return tokenId;
  }


// Mint multiple nfts 
  function multiMint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 1);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply, "Minting over");
    require(multiMintKeyUsed[address(multiMintLock)][msg.sender] == false, "You have already used this Multi mint key");


    if (msg.sender != owner()) {
      require(squadMember[msg.sender] == true, "Only members can mint a squad");
      require(_hasValidMultiMintKey(msg.sender), "Need valid multi mint key to mint ");
      multiMintKeyUsed[address(multiMintLock)][msg.sender] = true;
    }

    // Todo
    // - Charge DGTokens for multiMinting
    for (uint256 i = 1; i <= _mintAmount; i++) {
      _tokenIdCounter.increment();
      uint256 tokenId = _tokenIdCounter.current();
      _safeMint(msg.sender, tokenId);
      // _safeMint(msg.sender, supply + i);
    }
  }

// @Dev Get the number of nfts by tokenIds an address has
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

  //only owner
  // Display hidden nft URI
  function reveal() public onlyOwner {
      revealed = true;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  
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

  

    // This will payout DGTokenVendor 20% of the contract balance.
    // =============================================================================
    // (bool hs, ) = payable(vendorAddress).call{value: address(this).balance * 20 / 100}("");
    // require(hs);


    // This will pay HashLips 2% of the initial sale.
    // You can remove this if you want, or keep it in to support HashLips and his channel.
    // =============================================================================
    (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 2 / 100}("");
    require(hs);
    // =============================================================================
    
  // This will pay the DreadGang Team 8% of the initial sale.
    // You can remove this if you want, or keep it in to support DreadGang.
    // =============================================================================
    // (bool hs, ) = payable(DreadGangCore).call{value: address(this).balance * 8 / 100}("");
    // require(hs);
    // ====

    // This will payout the owner the remainder( 70% ) of the contract balance.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
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