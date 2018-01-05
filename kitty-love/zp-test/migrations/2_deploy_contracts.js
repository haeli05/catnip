const klc = artifacts.require("klc")
const crowdsale = artifacts.require("Crowdsale")
const kltest = artifacts.require("./kl.sol")
module.exports = function(deployer, network, accounts) {
		const goal = new web3.BigNumber(2)
		const wallet = accounts[0]
		const startTime=web3.eth.getBlock(web3.eth.blockNumber).timestamp + 1
		const endTime = startTime + (60*10) // 10 minutes
		const rate = new web3.BigNumber(1)
		deployer.deploy(crowdsale, goal,startTime, endTime, rate, wallet)
		//deployer.deploy(klc,goal)
};
