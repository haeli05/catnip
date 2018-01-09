const klc = artifacts.require("klc")
const crowdsale = artifacts.require("Crowdsale")
const kltest = artifacts.require("./kl.sol")
module.exports = function(deployer, network, accounts) {
		//goal, and rate are in Wei
		const goal = web3.toWei(2)
		const wallet = accounts[0]
		const startTime= web3.eth.getBlock(web3.eth.blockNumber).timestamp + 1;
		const endTime = startTime + (60*10) //10 minutes //60*48) // 60 seconds * 60  = 60 minutes *48 = 48 hours
		const rate = new web3.BigNumber(1)
		deployer.deploy(crowdsale, goal,startTime, endTime, rate, wallet)
};
