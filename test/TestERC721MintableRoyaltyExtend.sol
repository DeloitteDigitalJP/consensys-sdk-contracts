// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ERC721MintableRoyaltyExtend.sol";

contract TestERC721MintableRoyaltyExtend {
    ERC721MintableRoyaltyExtend public instance;

    function beforeEach() public {
        instance = ERC721MintableRoyaltyExtend(DeployedAddresses.ERC721MintableRoyaltyExtend());
    }

    function testNameAndSymbolSetCorrectlyInConstructor() public {
        Assert.equal(instance.name(), "My Test Royalty NFT", "name doesn't match");
        Assert.equal(instance.symbol(), "MTRNFT", "symbol doesn't match");
    }
}
