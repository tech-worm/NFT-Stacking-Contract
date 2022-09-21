const {ethers} = require('hardhat');
/** This is a function used to deploy contract */
const hre = require('hardhat');

async function main() {
  const StackingToken = await hre.ethers.getContractFactory('StackingToken');
  const _StackingToken = await StackingToken.deploy();
  console.log(
      'StackingToken deployed to:',
      _StackingToken.address,
  );
}

main().
    then(() => process.exit(0)).
    catch((error) => {
      console.error(error);
      process.exit(1);
    });