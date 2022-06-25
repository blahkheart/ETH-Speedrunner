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

contract DreadGangFactory is FactoryERC721, Ownable, DreadGang {
    using Strings for string;
    using Counters for Counters.Counter;


    // event Transfer(
    //     address indexed from,
    //     address indexed to,
    //     uint256 indexed tokenId
    // );
    event MintLock(
        address indexed newLockAddress
    );


    // address public proxyRegistryAddress;

    Counters.Counter private _tokenIdCounter;
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
     
    function _hasValidKey (address _account, IPublicLock _lock) private returns (bool) {
        IPublicLock lock = _lock;

        bool isMember = lock.getHasValidKey(_account);
        return isMember;
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

    function mint(IPublicLock _key, address _toAddress) public {
        _setOptionId(_key);
        require(!paused, "Minting is on pause.");
        require(dreadGang.totalSupply() < DREADGANG_SUPPLY, "Minting over");
        require(squadMember[msg.sender] == false, "Already part of the squad");
        require(canMint(_optionId), "Invalid optionId");

        // DreadGang dreadGang = DreadGang(nftAddress);
         if (_optionId == SINGLE_MINT_OPTION) {
            // if(owner() !== _msgSender()){
            //     squadMember[msg.sender] = true;
            // }
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            dreadGang._safeMint(_toAddress, tokenId);

        } else if (_optionId == MULTIPLE_MINT_OPTION) {
            for (
                uint256 i = 0;
                i < NUM_MEMBERS_IN_MULTIPLE_MINT_OPTION;
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
            numItemsAllocated = NUM_MEMBERS_IN_MULTIPLE_MINT_OPTION;
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
        require(!isMintLockAddressSet, "Minting Lock Address is already set"); 
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
    ) override public {
        mint(_tokenId, _to);
    }

    /**
     * Hack to get things to work automatically on OpenSea.
     * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
     */
    function ownerOf(uint256) override public view returns (address _owner) {
        return owner();
    }
}