// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interface/IFactoryERC721";
import "https://github.com/unlock-protocol/unlock/blob/master/packages/contracts/src/contracts/PublicLock/PublicLockV10.sol";
import "./DreadGang";

contract DreadGang is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Dread Gang NFT", "DREAD") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    _modifier onlyMember() {

    }
    
    function mintItem(address to, string memory uri) public returns (uint256) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
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

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
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

contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.05 ether;
  uint256 public maxSupply = 10000;
  uint256 public maxMintAmount = 20;
  bool public paused = false;
  bool public revealed = false;
  string public notRevealedUri;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply);

    if (msg.sender != owner()) {
      require(msg.value >= cost * _mintAmount);
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

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
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
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
    (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 5 / 100}("");
    require(hs);
    // =============================================================================
    
    // This will payout the owner 95% of the contract balance.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }
}


contract DreadGangFactory is FactoryERC721, Ownable {
    using Strings for string;
    using Counters for Counters.Counter;



    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event MintLock(
        address indexed newLockAddress
    )


    Counters.Counter private _tokenIdCounter;
    address public proxyRegistryAddress;
    address public nftAddress;
    DreadGang public dreadGang;
    string public baseURI = "https://ipfs.io/ipfs/";
    string public baseExtension = ".json";
    bool public paused = false;
    bool public revealed = false;
    string public notRevealedUri;

    //unlock protocol
    IPublicLock public mintLock;
    IPublicLock public multiMintLock;
    bool public isMintLockAddressSet = false; 

    mapping(address => bool) private squadMember;


    /*
     * Enforce the existence of only 100 OpenSea creatures.
     */
    uint256 DREADGANG_SUPPLY = 10000;

    /*
     * Three different options for minting Creatures (basic, premium, and gold).
     */
    uint256 NUM_OPTIONS = 2;
    uint256 _optionId;
    uint256 SINGLE_MINT_OPTION = 0;
    uint256 MULTIPLE_MINT_OPTION = 1;
    uint256 NUM_MEMBERS_IN_MULTIPLE_MINT_OPTION = 4;

    constructor(address _nftAddress) {
        nftAddress = _nftAddress;
        dreadGang = DreadGang(nftAddress);
        fireTransferEvents(address(0), owner());
    }

    function name() override external pure returns (string memory) {
        return "Dread Gang NFT Sale";
    }

    function symbol() override external pure returns (string memory) {
        return "DGNS";
    }

    function supportsFactoryInterface() override public pure returns (bool) {
        return true;
    }

    function numOptions() override public view returns (uint256) {
        return NUM_OPTIONS;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function transferOwnership(address newOwner) override public onlyOwner {
        address _prevOwner = owner();
        super.transferOwnership(newOwner);
        fireTransferEvents(_prevOwner, newOwner);
    }

    function fireTransferEvents(address _from, address _to) private {
        for (uint256 i = 0; i < NUM_OPTIONS; i++) {
            emit Transfer(_from, _to, i);
        }
    }

    // function _getHasValidKey (address _account) private view returns(bool) {
    //     return mintLock.gethasValidKey(_account);
    // }
     
    function _hasValidKey (address _account, IPublicLock _lock) private {
        IPublicLock memory lock = _lock;

        bool memory isMember = lock.gethasValidKey(_account);
        return isMember;
    }

    function _setOptionId (IPublicLock _lock) private returns(uint){
        IPublicLock memory lock = _lock;
        bool memory hasKey = lock.gethasValidKey(msg.sender);
        require(hasKey == true, "");
        if(mintLock() == address(lock)){
            _optionId = 0;
        } else if (multiMintLock() == address(lock)) {
            _optionId = 1;
        } else {
            _optionId = 2;
        }
        return _optionId;
    }

    function mint(address _key, address _toAddress) override public {
        _setOptionId(_key);
        require(!paused, "Minting is on pause.");
        require(dreadGang.totalSupply() < DREADGANG_SUPPLY, "Minting over");
        require(squadMember[msg.sender] == false, "Already part of the squad");
        require(canMint(_optionId), "Invalid optionId");


        // DreadGang dreadGang = DreadGang(nftAddress);
        if (_optionId == SINGLE_MINT_OPTION) {
            if(owner() !== _msgSender()){
                squadMember[msg.sender] = true;
            }
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            dreadGang._safeMint(_toAddress, tokenId);

        } else if (_optionId == MULTIPLE_MINT_OPTION) {
            for (
                uint256 i = 0;
                i < NUM_CREATURES_IN_MULTIPLE_MINT_OPTION;
                i++
            ) {
                _tokenIdCounter.increment();
                uint256 tokenId = _tokenIdCounter.current();
                dreadGang._safeMint(_toAddress, tokenId);
            }
        }
    }

    function canMint(uint256 _mintOptionId) override public view returns (bool) {
        if (_mintOptionId >= NUM_OPTIONS) {
            return false;
        }

       
        uint256 dreadGangSupply = dreadGang.totalSupply();

        uint256 numItemsAllocated = 0;
        if (_mintOptionId == SINGLE_MINT_OPTION) {
            numItemsAllocated = 1;
        } else if (_mintOptionId == MULTIPLE_MINT_OPTION) {
            numItemsAllocated = NUM_CREATURES_IN_MULTIPLE_MINT_OPTION;
        }
        return dreadGangSupply < (DREADGANG_SUPPLY - numItemsAllocated);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );
        
        if(revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    //only owner
    function reveal() public onlyOwner {
        revealed = true;
    }

    function setMintLockAddr (IPublicLock _lock) private onlyOwner {
        require(!isMintLockAddressSet, "Minting Lock Address is already set") 
         mintLock = _lock;
        isMintLockAddressSet = true; 
        emit MintLock( _lock);
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

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use transferFrom so the frontend doesn't have to worry about different method names.
     */
    function transferFrom(
        address,
        address _to,
        uint256 _tokenId
    ) public {
        mint(_tokenId, _to);
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function ownerOf(uint256) public view returns (address _owner) {
        return owner();
    }
}