//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    //implementing multiple inheritance

    string _baseTokenURI;
    //to compute tokenURI. if set, resultant uri is baseURI + tokenID

    uint256 public _price = 0.01 ether;
    //price of one NFT

    bool public _paused;
    //to pause the contract in case of emergency

    uint256 public maxTokenIds = 20;
    //stores the max number of NFTs allowed

    uint256 public tokenIds;
    //total number of tokenIds minted

    IWhitelist whitelist;
    //creates whitelist interface instance

    bool public presaleStarted;
    //to keep track whether presale started or not

    uint256 public presaleEnded;
    //timestamp of ending the presale

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract is currently paused!");
        _;
    }

    //ERC721 takes two args: 1. name and 2. symbol of our nft units
    //constructor to initialize baseURI and interface of whitelist contract
    constructor(string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    //function to start presale for the whitelisted address
    function startPresale() public onlyOwner {
        presaleStarted = true;

        //setting presale time as current timestamp + 5mins
        //timestamp syntax: (seconds, minutes, hours, days, years)
        presaleEnded = block.timestamp + 5 minutes;
    }

    //function to allow a user to mint one NFT per transaction during the presale
    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running!");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not Whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply!");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        //_safeMint is a safer version of the _mint function as it ensures that
        //if the address being minted to is a contract, then it knows how to deal with ERC721
        //if the address being minted to is not a contract, it works the same way as _mint
        _safeMint(msg.sender, tokenIds);
    }

    //function to allow user to mint 1NFT per transaction after presale ends
    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not yet ended!");
        require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply!");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    //_baseURI overrides the Openzeppelin's ERC721 implementation which by default returned an empty string for the baseURI
    function _baseURI() internal view virtual override returns(string memory) {
        return _baseTokenURI;
    }

    //function to send all the ether in the contract to the owner of the contract
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    //function to receive ETH, msg.data should be empty
    receive() external payable {}

    //called when msg.data is non-empty
    fallback() external payable {}
}