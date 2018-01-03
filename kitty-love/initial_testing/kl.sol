pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract owned {
	address public owner;

	function owned() public{
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner)public onlyOwner {
		owner = newOwner;
	}
}
contract TokenERC20 is owned{
	// Public variables of the token
	string public name;
	string public symbol;
	uint8 public decimals;
	// 18 decimals is the strongly suggested default, avoid changing it
	uint256 public totalSupply;
	// This creates an array with all balances
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;
	
	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint256 value);
	event IncreaseSupply(uint value,address indexed to);
	event DecreaseSupply(uint value, address indexed from);
	
	function TokenERC20(
		uint256 initialSupply,
		string tokenName,
		string tokenSymbol
	) public {
		totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
		balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
		name = tokenName;                                   // Set the name for display purposes
		symbol = tokenSymbol;                               // Set the symbol for display purposes
	}

	function _transfer(address _from, address _to, uint _value) internal {
		// Prevent transfer to 0x0 address. Use burn() instead
		require(_to != 0x0);
		// Check if the sender has enough
		require(balanceOf[_from] >= _value);
		// Check for overflows
		require(balanceOf[_to] + _value > balanceOf[_to]);
		// Save this for an assertion in the future
		uint previousBalances = balanceOf[_from] + balanceOf[_to];
		// Subtract from the sender
		balanceOf[_from] -= _value;
		// Add the same to the recipient
		balanceOf[_to] += _value;
		Transfer(_from, _to, _value);
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}

	function transfer(address _to, uint256 _value) public {
		_transfer(msg.sender, _to, _value);
	}


	function approve(address _spender, uint256 _value) public
	returns (bool success) {
		allowance[msg.sender][_spender] = _value;
		return true;
	}

	function approveAndCall(address _spender, uint256 _value, bytes _extraData)
	public
	returns (bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;
		}
	}

	function increaseSupply(uint value, address to) public returns (bool) {
		require(msg.sender == owner);
		totalSupply = safeAdd(totalSupply, value);
		balanceOf[owner] = safeAdd(balanceOf[owner], value);
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
		balanceOf[owner] = safeSub(balanceOf[owner], value);
		totalSupply = safeSub(totalSupply, value);  
		Transfer(from, 0, value);
		return true;
	}

	function safeSub(uint a, uint b)pure internal returns (uint) {
		if (b > a) { return; }
		return a - b;
	}
	function checkBalance()view public returns (uint){
		return totalSupply;
	}
}
