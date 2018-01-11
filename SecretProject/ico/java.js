var abi=[
{
	"constant": true,
	"inputs": [],
	"name": "rate",
	"outputs": [
	{
		"name": "",
		"type": "uint256"
	}
	],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
},
{
	"constant": true,
	"inputs": [],
	"name": "endTime",
	"outputs": [
	{
		"name": "",
		"type": "uint256"
	}
	],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
},
{
	"constant": true,
	"inputs": [],
	"name": "weiRaised",
	"outputs": [
	{
		"name": "",
		"type": "uint256"
	}
	],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
},
{
	"constant": true,
	"inputs": [],
	"name": "wallet",
	"outputs": [
	{
		"name": "",
		"type": "address"
	}
	],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
},
{
	"constant": true,
	"inputs": [],
	"name": "startTime",
	"outputs": [
	{
		"name": "",
		"type": "uint256"
	}
	],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
},
{
	"constant": false,
	"inputs": [
	{
		"name": "beneficiary",
		"type": "address"
	}
	],
	"name": "buyTokens",
	"outputs": [],
	"payable": true,
	"stateMutability": "payable",
	"type": "function"
},
{
	"constant": true,
	"inputs": [],
	"name": "hasEnded",
	"outputs": [
	{
		"name": "",
		"type": "bool"
	}
	],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
},
{
	"constant": true,
	"inputs": [],
	"name": "token",
	"outputs": [
	{
		"name": "",
		"type": "address"
	}
	],
	"payable": false,
	"stateMutability": "view",
	"type": "function"
},
{
	"inputs": [
	{
		"name": "_startTime",
		"type": "uint256"
	},
	{
		"name": "_endTime",
		"type": "uint256"
	},
	{
		"name": "_rate",
		"type": "uint256"
	},
	{
		"name": "_wallet",
		"type": "address"
	}
	],
	"payable": false,
	"stateMutability": "nonpayable",
	"type": "constructor"
},
{
	"payable": true,
	"stateMutability": "payable",
	"type": "fallback"
},
{
	"anonymous": false,
	"inputs": [
	{
		"indexed": true,
		"name": "purchaser",
		"type": "address"
	},
	{
		"indexed": true,
		"name": "beneficiary",
		"type": "address"
	},
	{
		"indexed": false,
		"name": "value",
		"type": "uint256"
	},
	{
		"indexed": false,
		"name": "amount",
		"type": "uint256"
	}
	],
	"name": "TokenPurchase",
	"type": "event"
}
];

var cAddress = "0x414af059bbeeb2e6d3a8f1b3736f41b1234a00e9";
window.addEventListener('load', function() {

	// Checking if Web3 has been injected by the browser (Mist/MetaMask)
	if (typeof web3 !== 'undefined') {
		// Use Mist/MetaMask's provider
		//web3js = new Web3(web3.currentProvider);
		var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
		console.log('No web3? You should consider trying MetaMask!')

	} else {
		console.log('No web3? You should consider trying MetaMask!')
			// fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
			web3js = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
	}

	// Now you can start your app & access web3 freely:
	startApp()

})


function startApp(){

	var version = web3.version.getNetwork;
	var klc= web3.eth.contract(abi).at(cAddress);

	waitForClick(klc);
}

function waitForClick(klc){

	
  var button = document.getElementById('send-button');
   console.log("good for click");
   button.addEventListener('click',function(){
   	console.log("Clicked");

	var amount = document.getElementById('amount');
	var amt = web3.toWei(amount.value);
	var sender=document.getElementById('from');
	var from1= sender.value;
	console.log(amt);
	console.log(web3.eth.accounts);
	console.log(from);
	console.log(cAddress);
	
	klc.buyTokens(from1,{value: amt},function(){});	
   });

}
