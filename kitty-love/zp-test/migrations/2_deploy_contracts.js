const crowdsale = artifacts.require("./Crowdsale")
const kl = artifacts.require("./klrinkeby")
module.exports = function(deployer, network, accounts) {
		//goal, and rate are in Wei
		const goal = web3.toWei(2)
		const wallet = "0x5C5dD9F3Cc5fA4cB4C8376BAa8991586A35774C3"
		const startTime= web3.eth.getBlock(web3.eth.blockNumber).timestamp+120;
		const endTime = startTime+(60*60*48); // 60 seconds * 60  = 60 minutes *48 = 48 hours
		const rate = 1;
		deployer.deploy(kl)
		deployer.deploy(crowdsale, goal,startTime, endTime, rate, wallet)
};
