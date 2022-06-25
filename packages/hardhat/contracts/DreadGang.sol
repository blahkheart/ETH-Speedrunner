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
  uint256 public cost = 0.05 ether;
  uint256 public maxSupply = 10000;
  uint256 public maxMintAmount = 20;
  bool public paused = false;
  bool public revealed = false;
  string public notRevealedUri;
  uint256 _optionId;
  Counters.Counter private _tokenIdCounter;

  address public unlockRinkeby = 0xD8C88BE5e8EB88E38E6ff5cE186d764676012B0b;
  address public publicLockRinkeby = 0xa55F8Ba16C5Bb580967f7dD94f927B21d0acF86c;
  IPublicLock public publicLock;
  IUnlockV11 public unlock;
  bool public isPublicLockAddressSet = false; // tracks whether a lock address has been set.
  IPublicLock public mintLock;
  IPublicLock public multiMintLock;
  bool isMultiMintLockAddressSet = false;

  mapping(address => bool) private squadMember;
  mapping(address => mapping(address => bool))private multiMintKeyUsed;
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
    require(squadMember[msg.sender] == true, "You do not have a valid key to access this functionality");
    _;
  }

  function _setOptionId (IPublicLock _lock) private returns(uint){
    IPublicLock lock = _lock;
    bool hasKey = lock.getHasValidKey(msg.sender);
    require(hasKey == true, "");
    address mintLockAddress = address(mintLock);
    address multiMintLockAddress = address(multiMintLock);
    if(mintLockAddress == address(lock)){
        _optionId = 0;
    } else if (multiMintLockAddress == address(lock)) {
        _optionId = 1;
    } else {
        _optionId = 2;
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

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
  // function getChainId() public view returns(uint) {
  //   return IUnlockV11(unlockRinkeby).chainId();
  // }
  // function getHasValidKey(
  //   address _user
  // ) external view returns (bool);


  // function mintItem(address to, string memory uri) public onlyMember returns (uint256) {
  //   _tokenIdCounter.increment();
  //   uint256 tokenId = _tokenIdCounter.current();
  //   _safeMint(to, tokenId);
  //   _setTokenURI(tokenId, uri);
  //   return tokenId;
  // }

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

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _tokenIdCounter.increment();
      uint256 tokenId = _tokenIdCounter.current();
      _safeMint(msg.sender, tokenId);
      // _safeMint(msg.sender, supply + i);
    }
  }

  // function walletOfOwner(address _owner)
  //   public
  //   view
  //   returns (uint256[] memory)
  // {
  //   uint256 ownerTokenCount = balanceOf(_owner);
  //   uint256[] memory tokenIds = new uint256[](ownerTokenCount);
  //   for (uint256 i; i < ownerTokenCount; i++) {
  //     tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
  //   }
  //   return tokenIds;
  // }

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
    // This will pay HashLips 5% of the initial sale.
    // You can remove this if you want, or keep it in to support HashLips and his channel.
    // =============================================================================
    (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 2 / 100}("");
    require(hs);
    // =============================================================================
    
    // This will payout the owner 95% of the contract balance.
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