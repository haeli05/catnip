pragma solidity ^0.4.16;

import "../node_modules/zeppelin-solidity/contracts/token/MintableToken.sol"; 
contract klrink is MintableToken {
	string  public name="kltest";
	string  public symbol="kltest";
	uint8 public decimals=18;
	uint256  public totalSupply=100;

	event IncreaseSupply(uint value,address indexed to);
	event DecreaseSupply(uint value, address indexed from);
	
		
	function increaseSupply(uint value, address to) public returns (bool) {
		require(msg.sender == owner);
		totalSupply = safeAdd(totalSupply, value);
		balances[owner] = safeAdd(balances[owner], value);
		Transfer(0, to, value);
		return true;
	}
	function safeAdd(uint a, uint b)pure internal returns (uint) {
		if (a + b < a) { return; }
		return a + b;
	}
	//Function decreases supply
	function decreaseSupply(uint value, address from)public returns (bool) {
		require(msg.sender == owner);
		balances[owner] = safeSub(balances[owner], value);
		totalSupply = safeSub(totalSupply, value);  
		Transfer(from, 0, value);
		return true;
	}

	function safeSub(uint a, uint b)pure internal returns (uint) {
		if (b > a) { return; }
		return a - b;
	}
	function checkSupply()view public returns (uint){
		return totalSupply;
	}
}

