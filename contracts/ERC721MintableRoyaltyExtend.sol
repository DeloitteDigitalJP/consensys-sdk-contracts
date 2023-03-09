// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// Name of contract cannot be empty.
error NameIsEmpty();
/// Token URI of token to be minted cannot be empty.
error TokenURIIsEmpty();
/// ContractURI cannot be empty;
error ContractURIIsEmpty();

contract ERC721MintableRoyaltyExtend is ERC721URIStorage, ERC2981, AccessControl, Ownable {
    using Counters for Counters.Counter;
    /// @dev Counter auto-incrementating NFT tokenIds, default: 0
    Counters.Counter private _tokenIdCounter;
    string private _contractURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event ContractDeployed(address contractAddress_);

    /// @notice The account deploying the contract will have the minter role and will be able to grand other accounts.
    /// @notice The contract is built with only a name & a symbol as metadata. Each NFT metadata will be given at mint time.
    constructor(
        string memory name_,
        string memory symbol_,
        string memory contractURI_
    ) ERC721(name_, symbol_) {
        if (!(bytes(name_).length > 1)) {
            revert NameIsEmpty();
        }
        _contractURI = contractURI_;
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());

        emit ContractDeployed(address(this));
    }

    /// @notice NFT minting with metadata i.e tokenURI
    /// @notice Each mint will increment the tokenId, starting from 0
    ///#if_succeeds old(balanceOf(to_)) + 1 == balanceOf(to_);
    function mintWithTokenURI(address to_, string memory tokenURI_)
        public
        onlyRole(MINTER_ROLE)
        returns (bool)
    {
        if (!(bytes(tokenURI_).length > 1)) {
            revert TokenURIIsEmpty();
        }
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to_, tokenId);
        _setTokenURI(tokenId, tokenURI_);
        return true;
    }

    ///#if_succeeds let receiver, _ := royaltyInfo(0, 10000) in receiver == receiver_;
    function setRoyalties(address receiver_, uint96 feeNumerator_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setDefaultRoyalty(receiver_, feeNumerator_);
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    ///#if_succeeds let receiver, _ := royaltyInfo(tokenId_, 10000) in receiver == receiver_;
    function setTokenRoyalty(uint256 tokenId_, address receiver_, uint96 feeNumerator_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_exists(tokenId_), "ERC721MintableRoyaltyExtend: setTokenRoyalty for nonexistent token");

        _setTokenRoyalty(tokenId_, receiver_, feeNumerator_);
    }

    ///#if_succeeds (keccak256(abi.encodePacked((_contractURI))) == keccak256(abi.encodePacked((contractURI_))));
    function setContractURI(string memory contractURI_)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (!(bytes(contractURI_).length > 1)) {
            revert ContractURIIsEmpty();
        }
        _contractURI = contractURI_;
    }

    // Overrides

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        override(ERC721, ERC2981, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId_);
    }
}
