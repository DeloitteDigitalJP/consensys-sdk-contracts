var NFT = artifacts.require("NFT");

module.exports = function(deployer) {
  deployer.deploy(NFT, "My Test NFT", "MTNFT");
};
