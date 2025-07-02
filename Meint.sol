// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

contract MeIntNFT is ERC721A, Ownable, ReentrancyGuard {
  using Strings for uint256;

  uint256 public constant MAX_SUPPLY = 3125;
  uint256 public constant AVAILABLE_METADATA = 400; // number of real metadata files

  string public baseTokenURI;
  string public uriSuffix = ".json";

  mapping(address => bool) public hasMinted;
  mapping(string => uint256) public comboToTokenId;
  mapping(uint256 => string) public tokenIdToCombo;
  uint256 public nextTokenId = 1;

constructor(string memory _baseTokenURI) ERC721A("ME-int", "MEINT") Ownable(msg.sender) {
    baseTokenURI = _baseTokenURI;
}

  function mint(string memory combo) external nonReentrant {
    require(!hasMinted[msg.sender], "You have already minted.");
    require(totalSupply() + 1 <= MAX_SUPPLY, "Max supply reached.");

    uint256 tokenId = nextTokenId;
    hasMinted[msg.sender] = true;
    comboToTokenId[combo] = tokenId;
    tokenIdToCombo[tokenId] = combo;
    _safeMint(msg.sender, 1);
    nextTokenId++;
  }

  function mintForAddress(address _receiver, string memory combo) external onlyOwner {
    require(totalSupply() + 1 <= MAX_SUPPLY, "Max supply reached.");

    uint256 tokenId = nextTokenId;
    comboToTokenId[combo] = tokenId;
    tokenIdToCombo[tokenId] = combo;
    _safeMint(_receiver, 1);
    nextTokenId++;
  }

  function getMetadataIdFromCombo(string memory combo) public pure returns (uint256) {
    bytes memory b = bytes(combo);
    require(b.length == 5, "Invalid combo length");

    uint256 index = 0;
    for (uint256 i = 0; i < 5; i++) {
      require(b[i] >= "A" && b[i] <= "E", "Invalid character");
      index = index * 5 + (uint8(b[i]) - 65); // 'A' is 65
    }

    return (index % AVAILABLE_METADATA) + 1;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    string memory combo = tokenIdToCombo[tokenId];
    uint256 metadataId = getMetadataIdFromCombo(combo);
    return string(abi.encodePacked(baseTokenURI, metadataId.toString(), uriSuffix));
  }

function walletOfOwner(address owner) external view returns (uint256[] memory) {
    uint256 balance = balanceOf(owner);
    uint256[] memory tokenIds = new uint256[](balance);
    uint256 tokenIndex = 0;
    uint256 supply = _totalMinted();

    for (uint256 i = _startTokenId(); i < supply + _startTokenId(); i++) {
        if (_exists(i) && ownerOf(i) == owner) {
            tokenIds[tokenIndex++] = i;
        }
    }

    return tokenIds;
}


  function setBaseTokenURI(string memory _baseTokenURI) external onlyOwner {
    baseTokenURI = _baseTokenURI;
  }

  function setUriSuffix(string memory _uriSuffix) external onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }
}
