module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  
	networks : {
		development :{
			host: 'localhost',
			port: 8545,
			network_id: '*'	
		}, 
		rinkeby : {
			host: 'localhost',
			port: 8545,
			from: '0xe8a387EFCC65f0ca362AC2780Ff540F90F7576c0',
			network_id: 4
		}
	}
};
