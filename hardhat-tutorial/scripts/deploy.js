const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env"});
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");

async function main() {

  //address of the whitelist contract address
  const whitelistContract = WHITELIST_CONTRACT_ADDRESS;

  //URL from where we can extract the metadata for a crypto dev NFT
  const metadataURL = METADATA_URL; //data of one NFT

  const cryptoDevsContract = await ethers.getContractFactory("CryptoDevs");
  const deployedCryptoDevsContract = await cryptoDevsContract.deploy(
    metadataURL,
    whitelistContract
  );  //params of constructor in contract

  await deployedCryptoDevsContract.deployed();

  console.log("CryptoDevs Contract address: ", deployedCryptoDevsContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });