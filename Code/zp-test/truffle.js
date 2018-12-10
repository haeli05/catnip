require('babel-register')
module.exports = {
	// See <http://truffleframework.com/docs/advanced/configuration>
	// to customize your Truffle configuration!

	networks : {
		development :{
			host: 'localhost',
			port: 8545,
			network_id: '*'	
		}, 
		rinkeby: {
			host: "localhost", // Connect to geth on the specified
			port: 8545,
			network_id: 4,
			gas: 6612388,
			from: "6c6916db64aec17ab1f98823cecec9414d7591bd"
		}
	}
};
