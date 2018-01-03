const crowdsale = artifacts.require("./klcrowdsale.sol")
const kltest = artifacts.require("./kltest.sol")
const eth = web3.eth
module.exports = function(deployer, network, accounts) {
		const ifSuccessfulSendTo = accounts[0]
		const fundingGoalInEthers = 2
		const durationInMinutes =  60// 6 minutes
		const etherCostOfEachToken = new web3.BigNumber(1)
		const addressOfTokenUsedAsReward =   
		deployer.deploy(kltest)

		deployer.deploy(ifSuccessfulSendTo,uint fundingGoalInEthers,uint durationInMinutes,uint etherCostOfEachToken,address addressOfTokenUsedAsReward)


/**
 * const fs = require("fs");
const solc = require('solc')

let source = fs.readFileSync('nameContract.sol', 'utf8');
let compiledContract = solc.compile(source, 1);
let abi = compiledContract.contracts['nameContract'].interface;
let bytecode = compiledContract.contracts['nameContract'].bytecode;
let gasEstimate = web3.eth.estimateGas({data: bytecode});
let MyContract = web3.eth.contract(JSON.parse(abi));

var myContractReturned = MyContract.new(param1, param2, {
   from:mySenderAddress,
   data:bytecode,
   gas:gasEstimate}, function(err, myContract){
    if(!err) {
       // NOTE: The callback will fire twice!
       // Once the contract has the transactionHash property set and once its deployed on an address.

       // e.g. check tx hash on the first call (transaction send)
       if(!myContract.address) {
           console.log(myContract.transactionHash) // The hash of the transaction, which deploys the contract
       
       // check address on the second call (contract deployed)
       } else {
           console.log(myContract.address) // the contract address
       }

       // Note that the returned "myContractReturned" === "myContract",
       // so the returned "myContractReturned" object will also get the address set.
    }
  });

// Deploy contract syncronous: The address will be added as soon as the contract is mined.
// Additionally you can watch the transaction by using the "transactionHash" property
var myContractInstance = MyContract.new(param1, param2, {data: myContractCode, gas: 300000, from: mySenderAddress});
myContractInstance.transactionHash // The hash of the transaction, which created the contract
myContractInstance.address // undefined at start, but will be auto-filled later
**/


};
